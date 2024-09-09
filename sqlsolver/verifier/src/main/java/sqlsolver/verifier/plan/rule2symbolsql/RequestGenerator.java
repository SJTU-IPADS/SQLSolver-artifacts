package sqlsolver.verifier.plan.rule2symbolsql;

import java.util.*;

import sqlsolver.superopt.constraint.Constraint;
import sqlsolver.superopt.fragment.*;
import sqlsolver.superopt.substitution.Substitution;

public class RequestGenerator {

  private final Substitution rule;
  private List<Constraint> srcConstraints = new ArrayList<>();
  private List<Constraint> dstConstraints = new ArrayList<>();
  private List<Constraint> constraints = new ArrayList<>();
  private Fragment srcTemplate;
  private Fragment dstTemplate;
  private EqConstraintsUnionFind eqClasses;
  private final SymbolNaming naming;
  private final boolean onlyIc;
  private HashMap<Symbol, String> attrsSchemaMap = new HashMap<>(); // key: each attribute symbol, value: the predecessor's relation from which the attribute comes from
  private HashMap<Op, String> opSchemaMap = new HashMap<>();       // key: each operator, value: relation symbol of this Op, (if none, create one)
  private int schemaId = 0;
  private HashMap<String, String> relationRenameMapping = new HashMap<>();

  public RequestGenerator(Substitution rule, boolean onlyIc) {
    this.rule = rule;
    srcTemplate = rule._0();
    dstTemplate = rule._1();
    naming = rule.naming();
    ArrayList<Constraint> attrSubTable = new ArrayList<>();
    ArrayList<Constraint> attrSubRelation = new ArrayList<>();
    for (Constraint constraint : rule.constraints()) {
      if (isSrcConstraint(srcTemplate.symbols(), constraint)) {
        srcConstraints.add(constraint);
      } else {
        dstConstraints.add(constraint);
      }
      if (constraint.kind() == Constraint.Kind.AttrsSub) {
        if (constraint.symbols()[1].kind() == Symbol.Kind.TABLE)
          attrSubTable.add(constraint);
        else
          attrSubRelation.add(constraint);
      } else {
        constraints.add(constraint);
      }
    }
    attrSubRelation.addAll(constraints);
    attrSubTable.addAll(attrSubRelation);
    constraints = attrSubTable;
    Symbols symbols = Symbols.merge(srcTemplate.symbols(), dstTemplate.symbols());
    eqClasses = new EqConstraintsUnionFind(symbols, naming, constraints);
    this.onlyIc = onlyIc;
    this.initSchemaId();
    try {
      inferAttrsSchema(srcTemplate.root());
      inferAttrsSchema(dstTemplate.root());
    } catch (Exception e) {
      e.printStackTrace();
    }
    initRelationRenameMapping();
  }

  private void initRelationRenameMapping() {
    for (Symbol sym : srcTemplate.symbols().symbolsOf(Symbol.Kind.TABLE)) {
      String name = naming.nameOf(sym);
      if (name.charAt(0) != 'r')
        relationRenameMapping.put(name, getNewSchemaName());
    }
    for (Symbol sym : srcTemplate.symbols().symbolsOf(Symbol.Kind.SCHEMA)) {
      String name = naming.nameOf(sym);
      if (name.charAt(0) != 'r')
        relationRenameMapping.put(name, getNewSchemaName());
    }
    for (Symbol sym : dstTemplate.symbols().symbolsOf(Symbol.Kind.TABLE)) {
      String name = naming.nameOf(sym);
      if (name.charAt(0) != 'r')
        relationRenameMapping.put(name, getNewSchemaName());
    }
    for (Symbol sym : dstTemplate.symbols().symbolsOf(Symbol.Kind.SCHEMA)) {
      String name = naming.nameOf(sym);
      if (name.charAt(0) != 'r')
        relationRenameMapping.put(name, getNewSchemaName());
    }
  }

  private String getNewSchemaName() {
    String schemaName = "r" + schemaId;
    schemaId = schemaId + 1;
    return schemaName;
  }

  private void initSchemaId() {
    schemaId = 1;
    String name = "r" + schemaId;
    Symbol sym = naming.symbolOf(name);
    while (sym != null) {
      schemaId ++;
      name = "r" + schemaId;
      sym = naming.symbolOf(name);
    }
  }

  private String schemaOfAttrSub(Symbol attr) {
    String schemaName = null;
    for (Constraint constraint : constraints) {
      if (constraint.kind() == Constraint.Kind.AttrsSub) {
        Symbol[] symbols = constraint.symbols();
        Symbol schema = symbols[1];
        Symbol curAttrs = symbols[0];
        if (curAttrs.equals(attr)) {
          schemaName = naming.nameOf(schema);
        }
      }
    }
    return schemaName;
  }

//  private static String getJoinSchema(SymbolNaming naming, Op joinOp) {
//    return switch (joinOp.kind()) {
//      case INNER_JOIN -> naming.nameOf(((InnerJoin) joinOp).table());
//      case LEFT_JOIN -> naming.nameOf(((LeftJoin) joinOp).table());
//      case CROSS_JOIN -> naming.nameOf(((CrossJoin) joinOp).table());
//      case FULL_JOIN -> naming.nameOf(((FullJoin) joinOp).table());
//      case RIGHT_JOIN -> naming.nameOf(((RightJoin) joinOp).table());
//      default -> null;
//    };
//  }

//  private void inferAttrSchema(Op curNode,  Symbol attr) throws Exception {
//    String schemaName = null;
//    if (opSchemaMap.containsKey(curNode)) {
//      schemaName = opSchemaMap.get(curNode);
//    } else {
//      switch(curNode.kind()) {
//        case INPUT -> {
//          schemaName = naming.nameOf(((Input) curNode).table());
//        }
//        case PROJ, PROJ_SIMPLE -> {
//          schemaName = naming.nameOf(((Proj) curNode).table());
//        }
//        case AGG, AGG_AVERAGE, AGG_COUNT, AGG_MAX, AGG_MIN, AGG_SUM -> {
//          schemaName = naming.nameOf(((Agg) curNode).r2());
//        }
//        case UNION, UNION_ALL, INTERSECT, EXCEPT, IN_SUB_FILTER, SIMPLE_FILTER, EXISTS_FILTER -> {
//          schemaName = opSchemaMap.get(curNode);
//          if (schemaName == null)
//            schemaName = getNewSchemaName();
//        }
//        case INNER_JOIN, LEFT_JOIN, CROSS_JOIN, RIGHT_JOIN, FULL_JOIN -> {
//          String joinSchemaName = getJoinSchema(naming, curNode);
//          schemaName = joinSchemaName;
//        }
//        default -> {
//          throw new Exception("Unsupported Op " + curNode.kind());
//        }
//      }
//      opSchemaMap.put(curNode, schemaName);
//    }
//    attrsSchemaMap.put(attr, schemaName);
//  }

  private String schemaOfAttribute(Symbol attrs, Op pre) {
    if (pre.kind() == OpKind.LEFT_JOIN || pre.kind() == OpKind.INNER_JOIN) {
      for (Constraint constraint : constraints) {
        if (constraint.kind() == Constraint.Kind.AttrsSub) {
          Symbol[] symbols = constraint.symbols();
          Symbol schema = symbols[1];
          Symbol curAttrs = symbols[0];
          if (curAttrs.equals(attrs)) {
            return naming.nameOf(schema);
          }
        }
      }
      return opSchemaMap.get(pre.predecessors()[0]);
    }
    return opSchemaMap.get(pre);
  }

  private void inferAttrsSchema(Op node) throws Exception {
    for (Op predecessor : node.predecessors()) {
      inferAttrsSchema(predecessor);
    }

    String schemaName = null;
    Symbol attr = null;
    switch(node.kind()) {
      case SIMPLE_FILTER, IN_SUB_FILTER: {
        AttrsFilter op = (AttrsFilter) node;
        schemaName = getNewSchemaName();
        attrsSchemaMap.put(op.attrs(), schemaOfAttribute(op.attrs(), op.predecessors()[0]));
        break;
      }
      case EXISTS_FILTER: {
//        ExistsFilter op = (ExistsFilter) node;
        schemaName = getNewSchemaName();
        break;
      }
      case PROJ: {
        Proj op = (Proj) node;
        schemaName = naming.nameOf(op.schema());
        attrsSchemaMap.put(op.attrs(), schemaOfAttribute(op.attrs(), op.predecessors()[0]));
        break;
      }
      case INPUT: {
        schemaName = naming.nameOf(((Input) node).table());
        break;
      }
      case AGG: {
        Agg op = (Agg) node;
        schemaName = naming.nameOf(op.schema());
        attrsSchemaMap.put(op.groupByAttrs(), schemaOfAttribute(op.groupByAttrs(), op.predecessors()[0]));
        attrsSchemaMap.put(op.aggregateAttrs(), schemaOfAttribute(op.aggregateAttrs(), op.predecessors()[0]));
        attrsSchemaMap.put(op.aggregateOutputAttrs(), schemaName);
        break;
      }
//      case AGG_AVERAGE, AGG_COUNT, AGG_MAX, AGG_MIN, AGG_SUM: {
//        Agg op = (Agg) node;
//        schemaName = naming.nameOf(op.r1());
//        attrsSchemaMap.put(op.a0(), opSchemaMap.get(op.predecessors()[0]));
//        attrsSchemaMap.put(op.a1(), opSchemaMap.get(op.predecessors()[0]));
//        attrsSchemaMap.put(op.a2(), schemaName);
//        break;
//      }
      case INNER_JOIN, LEFT_JOIN, RIGHT_JOIN, CROSS_JOIN: {
        Join op = (Join) node;
        schemaName = getNewSchemaName();
        attrsSchemaMap.put(op.lhsAttrs(), schemaOfAttribute(op.lhsAttrs(), op.predecessors()[0]));
        attrsSchemaMap.put(op.rhsAttrs(), schemaOfAttribute(op.rhsAttrs(), op.predecessors()[1]));
        break;
      }
      case UNION: {
//        Union op = (Union) node;
        schemaName = getNewSchemaName(); // opSchemaMap.get(op.predecessors()[0]);
        break;
      }
      // todo implement SORT and LIMIT
      default: {
        throw new Exception("not support op " + node.kind().name());
      }
    }
    opSchemaMap.put(node, schemaName);
  }

  /**
   * Generate an array that consists of the following fields:
   * <ul>
   *     <li>a plan template as the source plan template (this helps analyze relation between schemas and attribute lists);</li>
   *     <li>a SQL string as the source symbolic query;</li>
   *     <li>a SQL string as the destination symbolic query;</li>
   *     <li>constraints adapted to following verification in WeTune format;</li>
   * </ul>
   * Guarantees:
   * <ul>
   *     <li>Attribute list symbols must consist of an "a" and a number.</li>
   *     <li>Schema symbols must consist of an "s" and a number.</li>
   *     <li>Other symbols must not be in those forms.</li>
   * </ul>
   */
  public String[] translate() {
    try {
      final String[] result = new String[3];
      result[0] = renameRelations(stringOfSrcSQL());
      result[1] = renameRelations(stringOfDstSQL());
      result[2] = renameRelations(stringOfConstraints());
      return result;
    } catch (Exception e) {
      System.err.println("Unsupported Rule : " + rule.toString());
      e.printStackTrace();
      return null;
    }
  }

  private String renameRelations(String str) {
    for (String oldName : relationRenameMapping.keySet()) {
      str = str.replace(oldName, relationRenameMapping.get(oldName));
    }
    return str;
  }

//  private String stringOfSrcTemplate() {
//    String srcTemplateString = srcTemplate.stringify(rule.naming());
//    srcTemplateString = eqClasses.unifySymbolNames(srcTemplateString, Symbol.Kind.ATTRS);
//    srcTemplateString = eqClasses.unifySymbolNames(srcTemplateString, Symbol.Kind.RELATION);
//    return srcTemplateString;
//  }

  private boolean isSrcConstraint(Symbols symbols, Constraint constraint) {
    Symbol[] constraintSymbols = constraint.symbols();
    for (Symbol symbol : constraintSymbols) {
      if (!srcTemplate.symbols().contains(symbol))
        return false;
    }
    if (constraint.stringify(rule.naming()).contains("null")) {
      return false;
    }
    return true;
  }

  private String stringOfConstraints() {
    String result = "";
    HashSet<String> attrsOfSubConstraint = new HashSet<>();
    for (Constraint constraint : constraints) {
      if (constraint.kind() == Constraint.Kind.PredicateEq ||
          constraint.kind() == Constraint.Kind.FuncEq ||
          constraint.kind() == Constraint.Kind.AttrsEq ||
          constraint.kind() == Constraint.Kind.TableEq ||
          constraint.kind() == Constraint.Kind.SchemaEq)
        continue;
      String consStr = constraint.stringify(naming) + ";";
      consStr = eqClasses.unifySymbolNames(consStr, Symbol.Kind.TABLE);
      consStr = eqClasses.unifySymbolNames(consStr, Symbol.Kind.ATTRS);
      consStr = eqClasses.unifySymbolNames(consStr, Symbol.Kind.PRED);
      if (result.contains(consStr)) continue;
      if (constraint.kind() == Constraint.Kind.AttrsSub) {
        String attrName = consStr.substring("AttrsSub(".length(), consStr.indexOf(","));
        if (attrsOfSubConstraint.contains(attrName)) continue;
        else attrsOfSubConstraint.add(attrName);
      }
      result = result + consStr;
    }

    for (Symbol attr : attrsSchemaMap.keySet()) {
      String attrName = eqClasses.realSymbolName(naming.nameOf(attr), Symbol.Kind.ATTRS);
      boolean exists = false;
      for (Constraint c :constraints) {
        if (c.kind() == Constraint.Kind.AttrsSub) {
          String existAttrName = eqClasses.realSymbolName(naming.nameOf(c.symbols()[0]), Symbol.Kind.ATTRS);
          if (existAttrName.equals(attrName)) {
            exists = true;
            break;
          }
        }
      }
      if (exists) continue;
      String schemaName = eqClasses.realSymbolName(attrsSchemaMap.get(attr), Symbol.Kind.TABLE);
      String attrsSubStr = "AttrsSub(" + attrName + "," + schemaName + ")" + ";";
      if (!result.contains(attrsSubStr)) {
        result = result + attrsSubStr;
      }
    }
    return result;
  }

  private String stringOfSrcSQL() throws Exception {
    final TemplateToSQLTranslator translator = new TemplateToSQLTranslator(
            srcTemplate, naming, srcConstraints, eqClasses, true, attrsSchemaMap, opSchemaMap);
    return translator.translate();
  }

  private String stringOfDstSQL() throws Exception {
    final TemplateToSQLTranslator translator = new TemplateToSQLTranslator(
            dstTemplate, naming, constraints, eqClasses, false, attrsSchemaMap, opSchemaMap);
    return translator.translate();
  }

  private boolean notnullAttrs(Symbol attrsSymbol) {
    for (Constraint constraint : srcConstraints) {
      if (constraint.kind() == Constraint.Kind.NotNull) {
        Symbol[] symbols = constraint.symbols();
        if (attrsSymbol.equals(symbols[1]))
          return true;
      }
    }
    return false;
  }

  private boolean lackNotnullConstraint() {
    for (Constraint constraint : srcConstraints) {
      if (constraint.kind() == Constraint.Kind.Unique) {
        Symbol[] symbols = constraint.symbols();
        Symbol attrsSymbol = symbols[1];
        if (!notnullAttrs(attrsSymbol))
          return true;
      }
    }
    return false;
  }

}
