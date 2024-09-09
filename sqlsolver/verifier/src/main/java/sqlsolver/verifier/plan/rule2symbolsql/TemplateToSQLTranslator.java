package sqlsolver.verifier.plan.rule2symbolsql;

import java.util.*;

import sqlsolver.superopt.constraint.Constraint;
import sqlsolver.superopt.fragment.*;

enum SubqueryRequirement {
  QueryAlias,
  QueryNoAlias,
  PartialQueryAlias,
  PartialQueryNoAlias,
  NoneRequirement
}

public class TemplateToSQLTranslator {

  private final Fragment template;
  private final SymbolNaming naming;
  private final List<Constraint> constraints;
  private final EqConstraintsUnionFind eqClasses;
  private final boolean isSrc;
  private HashMap<Symbol, String> attrsSchemaMap = null;
  private HashMap<Op, String> opSchemaMap = null;

  public TemplateToSQLTranslator(
          Fragment template,
          SymbolNaming naming,
          List<Constraint> constraints,
          EqConstraintsUnionFind eqClasses,
          boolean isSrc,
          HashMap<Symbol, String> attrsSchemaMap,
          HashMap<Op, String> opSchemaMap) {
    this.template = template;
    this.naming = naming;
    this.constraints = constraints;
    this.eqClasses = eqClasses;
    this.isSrc = isSrc;
    this.attrsSchemaMap = attrsSchemaMap;
    this.opSchemaMap = opSchemaMap;
  }

  public String translate() throws Exception {
    String sql = tr(template.root());
    sql = eqClasses.unifySymbolNames(sql, Symbol.Kind.ATTRS);
    sql = eqClasses.unifySymbolNames(sql, Symbol.Kind.PRED);
//    sql = eqClasses.unifySymbolNames(sql, Symbol.Kind.RELATION);
    return sql;
  }

  private String tr(Op root) throws Exception {
    if (root == null) {
      return "";
    } else {
      return switch (root.kind()) {
        case PROJ -> trProj((Proj) root);
        case INPUT -> trInput((Input) root);
        case LEFT_JOIN -> trLeftJoin((LeftJoin) root);
//        case RIGHT_JOIN -> trRightJoin((RightJoin) root);
        case INNER_JOIN -> trInnerJoin((InnerJoin) root);
//        case CROSS_JOIN -> trCrossJoin((CrossJoin) root);
        case SIMPLE_FILTER -> trSimpleFilter((SimpleFilter) root);
        case IN_SUB_FILTER -> trInSubFilter((InSubFilter) root);
        case AGG -> trAgg((Agg) root);
        case EXISTS_FILTER -> trExistsFilter((ExistsFilter) root);
        case UNION -> trUnion((Union) root);
        case EXCEPT -> trExcept((Except) root);
        case INTERSECT -> trIntersect((Intersect) root);
        default -> throw new Exception("templateToSQLString not support " + root);
      };
    }
  }

  private SubqueryRequirement getRequirement(Op cur, Op successor) {
    if (isRootOp(cur)) {
      return SubqueryRequirement.QueryNoAlias;
    }

    switch (successor.kind()) {
      case INTERSECT, EXCEPT, UNION, EXISTS_FILTER -> {
        return SubqueryRequirement.QueryNoAlias;
      }
      case AGG, PROJ -> {
        return SubqueryRequirement.PartialQueryAlias;
      }
      case SIMPLE_FILTER -> {
        return SubqueryRequirement.QueryAlias;
      }
      case IN_SUB_FILTER -> {
        InSubFilter inSubFilter = (InSubFilter) successor;
        if (inSubFilter.predecessors()[1].equals(cur)) {
          return SubqueryRequirement.QueryNoAlias;
        } else {
          return SubqueryRequirement.QueryAlias;
        }
      }
      default -> {
        return SubqueryRequirement.NoneRequirement;
      }
    }
  }

  private String schemaOfAttribute(Symbol attrs, Op predecessor) {
    String tableName = attrsSchemaMap.get(attrs);
    if (tableName != null)
      return tableName;

    tableName = opSchemaMap.get(predecessor);
    if (tableName != null)
      return tableName;

    return "null";

//    for (Constraint constraint : constraints) {
//      if (constraint.kind() == Constraint.Kind.AttrsSub) {
//        Symbol[] symbols = constraint.symbols();
//        Symbol schema = symbols[1];
//        Symbol curAttrs = symbols[0];
//        if (curAttrs.equals(attrs)) {
//          return naming.nameOf(schema);
//        }
//      }
//    }
//    return null;
  }

  private boolean kindOfSuccessorIs(Op op, OpKind kind) {
    Op successor = op.successor();
    if (successor == null)
      return false;
    return successor.kind() == kind;
  }

  private boolean isRootOp(Op op) {
    if (op == null)
      return false;
    return op.equals(template.root());
  }

  private String trInput(Input node) {
    String tableName = naming.nameOf(node.table());
    String realName = eqClasses.realSymbolName(tableName, Symbol.Kind.TABLE);
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case QueryNoAlias -> "(select * from " + realName + ")";
      case PartialQueryAlias -> realName + " as " + tableName;
      case PartialQueryNoAlias -> realName;
      default -> "(select * from " + realName + ") as " + tableName;
    };
  }

  private String trProj(Proj node) throws Exception {
    String inputStr = tr(node.predecessors()[0]);
    Symbol attrs = node.attrs();
    String schema = schemaOfAttribute(attrs, node.predecessors()[0]);
    String selectList = naming.nameOf(attrs);
    if (schema != null)
      selectList = schema + "." + selectList;
    if (node.deduplicated())
      selectList = "distinct " + selectList;
    String sql = "(select " + selectList + " from " + inputStr + ") as " + naming.nameOf(node.schema());
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case QueryNoAlias, PartialQueryNoAlias -> "(select * from " + sql + ")";
      default -> sql;
    };
  }

  private String trInnerJoin(InnerJoin node) throws Exception {
    String lhsStr = tr(node.predecessors()[0]);
    String rhsStr = tr(node.predecessors()[1]);
    Symbol lhsAttrs = node.lhsAttrs();
    String lhsSchema = schemaOfAttribute(lhsAttrs, node.predecessors()[0]);
    Symbol rhsAttrs = node.rhsAttrs();
    String rhsSchema = schemaOfAttribute(rhsAttrs, node.predecessors()[1]);
    String lhsAttrStr = lhsSchema + "." + naming.nameOf(lhsAttrs);
    String rhsAttrStr = rhsSchema + "." + naming.nameOf(rhsAttrs);
    String sql = "(" + lhsStr + " inner join " + rhsStr + " on " + lhsAttrStr + "=" + rhsAttrStr + ")";
    if (isRootOp(node)) {
      return "select * from " + sql;
    } else {
      return sql;
    }
//    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
//    switch (subqueryRequirement) {
//      case QueryNoAlias, PartialQueryNoAlias -> {
//        return sql;
//      }
//      default -> {
//        return sql;
//      }
//    }
  }

//  private String trCrossJoin(CrossJoin node) throws Exception {
//    String lhsStr = tr(node.predecessors()[0]);
//    String rhsStr = tr(node.predecessors()[1]);
//    String sql = "(select * from " + lhsStr + " cross join " + rhsStr + ")";
//    String joinSchemaName = naming.nameOf(node.table());
//    boolean withJoinSchema = opSchemaMap.get(node).equals(joinSchemaName);
//    if (withJoinSchema) {
//      sql = sql + " as " + joinSchemaName;
//    }
//    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
//    switch (subqueryRequirement) {
//      case QueryNoAlias, PartialQueryNoAlias -> {
//        return withJoinSchema ? "(select * from " + sql + ")" : sql;
//      }
//      default -> {
//        return sql;
//      }
//    }
//  }

  private String trLeftJoin(LeftJoin node) throws Exception {
    String lhsStr = tr(node.predecessors()[0]);
    String rhsStr = tr(node.predecessors()[1]);
    Symbol lhsAttrs = node.lhsAttrs();
    String lhsSchema = schemaOfAttribute(lhsAttrs, node.predecessors()[0]);
    Symbol rhsAttrs = node.rhsAttrs();
    String rhsSchema = schemaOfAttribute(rhsAttrs, node.predecessors()[1]);
    String lhsAttrStr = (lhsSchema == null) ? naming.nameOf(lhsAttrs) : lhsSchema + "." + naming.nameOf(lhsAttrs);
    String rhsAttrStr = (rhsSchema == null) ? naming.nameOf(rhsAttrs) : rhsSchema + "." + naming.nameOf(rhsAttrs);
    String sql = "(" + lhsStr + " left join " + rhsStr + " on " + lhsAttrStr + "=" + rhsAttrStr + ")";
    if (isRootOp(node)) {
      return "select * from " + sql;
    } else {
      return sql;
    }
//    String joinSchemaName = naming.nameOf(node.table());
//    boolean withJoinSchema = opSchemaMap.get(node).equals(joinSchemaName);
//    if (withJoinSchema) {
//      sql = sql + " as " + joinSchemaName;
//    }
//    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
//    switch (subqueryRequirement) {
//      case QueryNoAlias, PartialQueryNoAlias -> {
//        return withJoinSchema ? "(select * from " + sql + ")" : sql;
//      }
//      default -> {
//        return sql;
//      }
//    }
  }

//  private String trRightJoin(RightJoin node) throws Exception {
//    String lhsStr = tr(node.predecessors()[0]);
//    String rhsStr = tr(node.predecessors()[1]);
//    Symbol lhsAttrs = node.a0();
//    String lhsSchema = schemaOfAttribute(lhsAttrs, node.predecessors()[0]);
//    Symbol rhsAttrs = node.a1();
//    String rhsSchema = schemaOfAttribute(rhsAttrs, node.predecessors()[1]);
//    String lhsAttrStr = (lhsSchema == null) ? naming.nameOf(lhsAttrs) : lhsSchema + "." + naming.nameOf(lhsAttrs);
//    String rhsAttrStr = (rhsSchema == null) ? naming.nameOf(rhsAttrs) : rhsSchema + "." + naming.nameOf(rhsAttrs);
//    String sql = "(select * from " + lhsStr + " right join " + rhsStr + " on " + lhsAttrStr + "=" + rhsAttrStr + ")";
//    String joinSchemaName = naming.nameOf(node.table());
//    boolean withJoinSchema = opSchemaMap.get(node).equals(joinSchemaName);
//    if (withJoinSchema) {
//      sql = sql + " as " + joinSchemaName;
//    }
//    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
//    switch (subqueryRequirement) {
//      case QueryNoAlias, PartialQueryNoAlias -> {
//        return withJoinSchema ? "(select * from " + sql + ")" : sql;
//      }
//      default -> {
//        return sql;
//      }
//    }
//  }

  private String trSimpleFilter(SimpleFilter node) throws Exception {
    String strOfPredecessor = tr(node.predecessors()[0]);
    String pred = naming.nameOf(node.predicate());
    String attrs = naming.nameOf(node.attrs());
    String schema = schemaOfAttribute(node.attrs(), node.predecessors()[0]);
    String sql = "(select * from " + strOfPredecessor + " where " + pred + "(" + schema + "." + attrs + ")) as " + opSchemaMap.get(node);
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case QueryNoAlias, PartialQueryNoAlias -> "(select * from " + sql + ")";
      default -> sql;
    };
  }

  private String trExistsFilter(ExistsFilter node) throws Exception {
    String strOfLeftPredecessor = tr(node.predecessors()[0]);
    String strOfRightPredecessor = tr(node.predecessors()[1]);
    String sql = "(select * from " + strOfLeftPredecessor + " where exists (" + strOfRightPredecessor + ")) as " + opSchemaMap.get(node);
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case QueryNoAlias, PartialQueryNoAlias -> "(select * from " + sql + ")";
      default -> sql;
    };
  }

  private String trInSubFilter(InSubFilter node) throws Exception {
    String lhsStr = tr(node.predecessors()[0]);
    String rhsStr = tr(node.predecessors()[1]);
    Symbol lhsAttrs = node.attrs();
    String lhsSchema = schemaOfAttribute(lhsAttrs, node.predecessors()[0]);
    String lhsAttrStr = (lhsSchema == null) ? naming.nameOf(lhsAttrs) : lhsSchema + "." + naming.nameOf(lhsAttrs);
    String sql = "(select * from ";
    sql = sql + lhsStr + " where " + lhsAttrStr + " in " + rhsStr + ") as " + opSchemaMap.get(node);
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case QueryNoAlias, PartialQueryNoAlias -> "(select * from " + sql + ")";
      default -> sql;
    };
  }

  private String trUnion(Union node) throws Exception {
    boolean isDeduplicate = node.deduplicated();
    String lhsStr = tr(node.predecessors()[0]);
    String rhsStr = tr(node.predecessors()[1]);
    String op = isDeduplicate ? " union " : " union all ";
    String sql =  "(" + lhsStr + op + rhsStr + ")";
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case PartialQueryAlias, QueryAlias -> sql + " as " + opSchemaMap.get(node);
      default -> sql;
    };
  }

  private String trIntersect(Intersect node) throws Exception {
    boolean isDeduplicate = node.deduplicated();
    String lhsStr = tr(node.predecessors()[0]);
    String rhsStr = tr(node.predecessors()[1]);
    String op = isDeduplicate ? " intersect " : " intersect all ";
    String sql =  "(" + lhsStr + op + rhsStr + ")";
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case PartialQueryAlias, QueryAlias -> sql + " as " + opSchemaMap.get(node);
      default -> sql;
    };
  }

  private String trExcept(Except node) throws Exception {
    boolean isDeduplicate = node.deduplicated();
    String lhsStr = tr(node.predecessors()[0]);
    String rhsStr = tr(node.predecessors()[1]);
    String op = isDeduplicate ? " except " : " except all ";
    String sql =  "(" + lhsStr + op + rhsStr + ")";
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case PartialQueryAlias, QueryAlias -> sql + " as " + opSchemaMap.get(node);
      default -> sql;
    };
  }

  private String trAgg(Agg node) throws Exception {
    String predecessorStr = tr(node.predecessors()[0]);
    Symbol groupbyAttrs = node.groupByAttrs();
    Symbol aggAttrs = node.aggregateAttrs();
    String aggFuncName = node.aggFuncKind().text();
    aggFuncName = (aggFuncName.equals("unknown")) ? "sum" : aggFuncName;
    String groupbySchema = schemaOfAttribute(groupbyAttrs, node.predecessors()[0]);
    String aggSchema = schemaOfAttribute(aggAttrs, node.predecessors()[0]);
    String groupbyList = naming.nameOf(groupbyAttrs);
    String aggList = naming.nameOf(aggAttrs);
    if (groupbySchema != null)
      groupbyList = groupbySchema + "." + groupbyList;
//    groupbyList = naming.nameOf(node.e0()) + "(" + groupbyList + ")";
    String distinct = node.deduplicated() ? " distinct " : " ";
    if (aggSchema != null)
      aggList = aggFuncName + "(" + distinct + aggSchema + "." + aggList + ") as " + naming.nameOf(node.aggregateOutputAttrs());
    String sql = "(select "
            + groupbyList + ", " + aggList
            + " from " + predecessorStr
            + " group by " + groupbyList
            + " having " + naming.nameOf(node.havingPred()) + "(" + naming.nameOf(node.aggregateOutputAttrs()) + ")) as " + opSchemaMap.get(node);
    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
    return switch (subqueryRequirement) {
      case PartialQueryNoAlias, QueryNoAlias -> "(select * from " + sql + ")";
      default -> sql;
    };
  }

//  private String trAggXX(Agg node) throws Exception {
//    String predecessorStr = tr(node.predecessors()[0]);
//    Symbol groupbyAttrs = node.a0();
//    Symbol aggAttrs = node.a1();
//    String aggFuncName = node.aggFuncKind().text();
//    String groupbySchema = schemaOfAttribute(groupbyAttrs, node.predecessors()[0]);
//    String aggSchema = schemaOfAttribute(aggAttrs, node.predecessors()[0]);
//    String groupbyList = naming.nameOf(groupbyAttrs);
//    String aggList = naming.nameOf(aggAttrs);
//    if (groupbySchema != null)
//      groupbyList = groupbySchema + "." + groupbyList;
//    if (aggSchema != null)
//      aggList = aggFuncName + "(" + aggSchema + "." + aggList + ") as " + naming.nameOf(node.r0());
//    String distinct = node.deduplicated() ? "distinct" : "";
//    String sql = "(select " + distinct + " "
//            + groupbyList +  ", " + aggList
//            + " from " + predecessorStr
//            + " group by " + groupbyList
//            + " having " + naming.nameOf(node.e0()) + "(" + aggSchema + "." + naming.nameOf(node.a2()) + ")) as " + naming.nameOf(node.r1());
//    SubqueryRequirement subqueryRequirement = getRequirement(node, node.successor());
//    return switch (subqueryRequirement) {
//      case PartialQueryNoAlias, QueryNoAlias -> "(select * from " + sql + ")";
//      default -> sql;
//    };
//  }
}

