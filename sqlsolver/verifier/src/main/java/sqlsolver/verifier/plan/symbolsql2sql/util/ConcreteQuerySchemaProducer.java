package sqlsolver.verifier.plan.symbolsql2sql.util;

import static sqlsolver.common.utils.ListSupport.map;
import static sqlsolver.verifier.plan.symbolsql2sql.util.SqlNodeSupport.*;

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.calcite.sql.*;
import org.apache.calcite.sql.dialect.MysqlSqlDialect;
import org.apache.calcite.sql.parser.SqlParseException;
import org.apache.calcite.sql.parser.SqlParserPos;
import org.apache.calcite.tools.Planner;
import sqlsolver.common.config.GlobalConfig;
import sqlsolver.sql.calcite.CalciteSupport;
import sqlsolver.verifier.plan.symbolsql2sql.attrtree.AttrTreeBuilder;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;
import sqlsolver.verifier.plan.symbolsql2sql.query.QueryValidityChecker;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicVerifier;
import sqlsolver.verifier.plan.symbolsql2sql.attrtree.AttrNodeInfo;
import sqlsolver.verifier.plan.symbolsql2sql.attrtree.Tree;

/**
 * Given a pair of symbolic queries and constraints, produce corresponding concrete queries.
 */
public class ConcreteQuerySchemaProducer {
  /**
   * Produce concrete query pairs according to the given symbolic query pair and constraints.
   * The symbolic queries and constraints should adhere to the same requirements
   * as {@link SymbolicVerifier#verify(String, String, List) SymbolicVerifier}.
   * @return a list of tuples, each consisting of 3 strings (the concrete query pair and a schema string)
   */
  public List<String[]> produce(String symbolicQuery0, String symbolicQuery1, List<Constraint> constraints) throws SqlParseException {
    // capitalize symbols (because Calcite adopts upper-case symbols)
    constraints = map(constraints, Constraint::capitalize);
    // classify constraints
    final List<Constraint> attrsSubs = new ArrayList<>();
    final List<Constraint> ics = new ArrayList<>();
    for (Constraint constraint : constraints) {
      if (constraint.type() == Constraint.Type.ATTRS_SUB) attrsSubs.add(constraint);
      else if (constraint.isIntegrityConstraint()) ics.add(constraint);
      // other constraints (...Eq) are ignored
    }
    // translate queries to AST
    final Planner parser = CalciteSupport.getParser();
    final SqlNode ast0 = parser.parse(symbolicQuery0);
    parser.close();
    final SqlNode ast1 = parser.parse(symbolicQuery1);
    // build a forest representing attribute list containment
    final AttrTreeBuilder treeBuilder = new AttrTreeBuilder();
//    final List<Tree<AttrNodeInfo>> attrForest = treeBuilder.build(ast0, ast1, attrsSubs);
    final List<Tree<Boolean>> attrForest = treeBuilder.buildForest(ast0, attrsSubs);
    if (GlobalConfig.LOG_LEVEL >= 2) {
      System.out.println("Forest:");
      for (Tree<Boolean> t : attrForest)
        System.out.print(t);
    }
    // generate concrete queries and a schema
    List<String[]> result = new ArrayList<>();
    enumerateQueryAndSchema(attrForest, ast0, ast1, ics, result);
    addDistinct(result, symbolicQuery0, symbolicQuery1);
    return result;
  }

  private void addDistinct(List<String[]> result, String src, String dst) {
    boolean srcHasDistinct = src.indexOf("count( distinct") >= 0;
    boolean dstHasDistinct = dst.indexOf("count( distinct") >= 0;
    for (String[] item : result) {
      if (srcHasDistinct)
        item[0] = item[0].replace("COUNT(", "COUNT(DISTINCT ");
      if (dstHasDistinct)
        item[1] = item[1].replace("COUNT(", "COUNT(DISTINCT ");
    }
  }

  private void enumerateAttrTree(List<Tree<Boolean>> attrForest, int index, SqlNode ast0, SqlNode ast1, List<Constraint> ics, List<String[]> result) {
    if (index == attrForest.size()) {
      final String[] pair = generateQueriesAndSchemas(attrForest, ast0, ast1, ics);
      if (pair != null) {
        for (int i = 1; i < 20; ++i) {
          String tableName = "R" + i;
          String schema = "\nCREATE TABLE " + tableName + "( C0 INT );";
          String selectStat = "SELECT * FROM " + tableName;
          if ((pair[0].indexOf(selectStat) >= 0 || pair[1].indexOf(selectStat) >= 0) && pair[2].indexOf(tableName)<0)
            pair[2] = pair[2] + schema;
        }
      }
      if (pair != null
              && QueryValidityChecker.check(pair[0], pair[2])
              && QueryValidityChecker.check(pair[1], pair[2])) {
        result.add(pair);
      }
    } else {
      List<Tree<Boolean>> thisTree =
              attrForest.get(index).flattenPreOrder().stream().filter(
              node -> !node.getChildren().isEmpty()
      ).toList();

      int nodeSize = thisTree.size();
      for (int i = 0; i < Math.pow(2, nodeSize); ++i) {
        for (int j = 0; j < nodeSize; ++j) {
          thisTree.get(j).extraAttr = ((i >> j) & 1) == 1;
        }
        enumerateAttrTree(attrForest, index + 1, ast0, ast1, ics, result);
      }
    }
  }

  private void enumerateQueryAndSchema(List<Tree<Boolean>> attrForest, SqlNode ast0, SqlNode ast1, List<Constraint> ics, List<String[]> result) {
    enumerateAttrTree(attrForest, 0, ast0, ast1, ics, result);
  }

  /**
   * Generate queries and schemas based on a possible case of attribute list containment
   * represented by flags of tree nodes.
   */
  private String[] generateQueriesAndSchemas(List<Tree<Boolean>> attrForest, SqlNode ast0, SqlNode ast1, List<Constraint> ics) {
    final String[] result = new String[3];
    // generate attribute list mapping
    final Map<String, List<String>> attrMap = new HashMap<>();   // key = r0, value = {c0, c1} or {expr}
    final AtomicInteger columnCounter = new AtomicInteger();
    for (Tree<Boolean> tree : attrForest) {
      if (tree.getTag().charAt(0) == 'R') {
        if (!generateAttrMap(tree, attrMap, columnCounter))
          return null;
      } else {
        replaceWithExpr(tree, attrMap);
      }
    }
    // generate one schema for each tree
    final StringBuilder schemaBuilder = new StringBuilder();
    for (Tree<Boolean> tree : attrForest) {
      if (tree.getTag().charAt(0) == 'R') {
        generateSchema(tree.getTag(), attrMap, ics, schemaBuilder);
      }
    }
    result[2] = schemaBuilder.toString();
    // generate queries
    result[0] = generateQuery(ast0, attrMap);
    if (result[0] == null)
      // invalid AST
      return null;
    result[1] = generateQuery(ast1, attrMap);
    if (result[1] == null)
      // invalid AST
      return null;
    return result;
  }

  private void replaceWithExprRecur(Tree<Boolean> tree, Map<String, List<String>> attrMap, String replace) {
    if (!attrMap.containsKey(tree.getTag())) {
      attrMap.put(tree.getTag(), Collections.singletonList(replace));
    }
    for (Tree<Boolean> child: tree.getChildren()) {
      replaceWithExprRecur(child, attrMap, replace);
    }
  }

  private void replaceWithExpr(Tree<Boolean> tree, Map<String, List<String>> attrMap) {
    String replace = tree.getTag();
    replaceWithExprRecur(tree, attrMap, replace);
  }

  /**
   * Generate attribute list mapping (i.e. what attributes each list contains)
   * based on flags of tree nodes.
   */
  private boolean generateAttrMap(Tree<Boolean> tree, Map<String, List<String>> attrMap, AtomicInteger columnCounter) {
    return generateAttrMapMulti(tree, attrMap, columnCounter);
  }

  private boolean generateAttrMapMulti(Tree<Boolean> tree, Map<String, List<String>> attrMap, AtomicInteger columnCounter) {
    final List<String> attrList = new ArrayList<>();
    // an attribute list at least contains its sub-lists
    for (Tree<Boolean> child : tree.getChildren()) {
      generateAttrMapMulti(child, attrMap, columnCounter);
      // not to add extra columns of children
      final List<String> childAttrs = new ArrayList<>(attrMap.get(child.getTag()));
      attrList.addAll(childAttrs);
    }
    // an attribute list contains other attributes if its "hasMoreColumns" flag is set
    if (tree.extraAttr || tree.getChildren().isEmpty()) {
      attrList.add("C" + columnCounter.getAndIncrement());
    }
    // register the attribute list
    attrMap.put(tree.getTag(), attrList);
    return true;
  }

  // SINGLE columns do not generate new columns
  // the successors all inherit their common ancestor
  private boolean generateAttrMapSingle(Tree<AttrNodeInfo> tree, Map<String, List<String>> attrMap, List<String> columns) {
    attrMap.put(tree.getTag(), new ArrayList<>(columns));
    final LinkedList<String> newColumns = new LinkedList<>(columns);
    if (tree.extraAttr.hasMoreColumns()) {
      if (newColumns.isEmpty()) return false;
      newColumns.removeLast();
    }
    for (Tree<AttrNodeInfo> child : tree.getChildren()) {
      generateAttrMapSingle(child, attrMap, newColumns);
    }
    return true;
  }

  private void generateSchema(String tableName, Map<String, List<String>> attrMap, List<Constraint> ics, StringBuilder sb) {
    // handle constrained attributes
    final Set<String> uniqueColumns = getSingleTableConstraintColumns(tableName, attrMap, ics, Constraint.Type.UNIQUE);
    final Set<String> notNullColumns = getSingleTableConstraintColumns(tableName, attrMap, ics, Constraint.Type.NOT_NULL);
    // print attributes and ICs
    sb.append("CREATE TABLE ").append(tableName).append(" ( \n");
    boolean first = true;
    for (String attr : attrMap.get(tableName)) {
      if (!first) sb.append(",\n");
      sb.append("    ").append(attr).append(" INT");
      if (uniqueColumns.contains(attr)) sb.append(" UNIQUE");
      if (notNullColumns.contains(attr)) sb.append(" NOT NULL");
      first = false;
    }
    for (Constraint ic : ics) {
      if (ic.type() == Constraint.Type.REFERENCE && ic.args().get(0).equals(tableName)) {
        final String foreignTableName = ic.args().get(2);
        final List<String> localKeys = attrMap.get(ic.args().get(1));
        final List<String> foreignKeys = attrMap.get(ic.args().get(3));
        sb.append(",\n    ").append("FOREIGN KEY (")
                .append(String.join(", ", localKeys))
                .append(") REFERENCES ").append(foreignTableName).append(" (")
                .append(String.join(", ", foreignKeys))
                .append(")");
      }
    }
    sb.append("\n);");
  }

  private Set<String> getSingleTableConstraintColumns(String tableName, Map<String, List<String>> attrMap, List<Constraint> ics, Constraint.Type icType) {
    final Set<String> result = new HashSet<>();
    if (icType != Constraint.Type.NOT_NULL && icType != Constraint.Type.UNIQUE) return result;
    for (Constraint ic : ics) {
      if (ic.type() == icType && ic.args().get(0).equals(tableName)) {
        result.addAll(attrMap.get(ic.args().get(1)));
      }
    }
    return result;
  }

  /**
   * Given a symbolic query AST with attribute lists,
   * replace each attribute list symbol with its corresponding attributes.
   */
  private String generateQuery(SqlNode ast, Map<String, List<String>> attrMap) {
    // Given mapping "a -> [c1,...,cN]",
    // convert "a" to "c1,...,cN"
    // and convert "t.a" to "t.c1,...,t.cN"
    ast = replace(ast, node -> {
      final SqlNode alias = getAlias(node);
      node = removeAlias(node);
      final SqlNode result;
      if (node instanceof SqlNodeList list) {
        // attr in a select list
        // a select list does not have an alias
        assert alias == null;
        final SqlNodeList newList = new SqlNodeList(SqlParserPos.ZERO);
        for (SqlNode item : list) {
          if (item instanceof SqlIdentifier id
                  && attrMap.containsKey(removeQualification(id).toString())) {
            // replace attr with a list of columns
            final String attrName = removeQualification(id).toString();
            final String qualification = getQualificationString(id);
            final List<String> columns = attrMap.get(attrName);
            newList.addAll(columnNamesToList(qualification, columns));
          } else {
            // remain unchanged
            newList.add(item);
          }
        }
        result = newList;
      } else if (node instanceof SqlBasicCall call) {
        // attr in a call (function, arithmetic operation, etc.)
        // a call may have an alias and its alias should be preserved
        final List<SqlNode> newOperands = new ArrayList<>();
        for (SqlNode operand : call.getOperandList()) {
          // check whether attr is among the operands
          if (operand instanceof SqlIdentifier id) {
            final String attrName = removeQualification(id).toString();
            if (attrMap.containsKey(attrName)) {
              // found attr; replace it
              final List<String> columns = attrMap.get(attrName);
              final String qualification = getQualificationString(id);
              newOperands.addAll(columnNamesToList(qualification, columns));
            } else {
              newOperands.add(operand);
            }
          } else {
            newOperands.add(operand);
          }
        }
        result = new SqlBasicCall(call.getOperator(), newOperands, SqlParserPos.ZERO);
      } else if (node instanceof SqlSelect select) {
        // empty GROUP BY should be handled differently
        final SqlNodeList groups = select.getGroup();
        if (groups != null
                && groups.size() == 1
                && groups.get(0) instanceof SqlIdentifier id
                && attrMap.containsKey(removeQualification(id).toString())) {
          final SqlSelect newSelect = (SqlSelect) select.clone(SqlParserPos.ZERO);
          final SqlNodeList newGroups;
          final String qualification = getQualificationString(id);
          final List<String> columns = attrMap.get(removeQualification(id).toString());
          if (columns.isEmpty()) {
            // empty GROUP BY
            newGroups = null;
          } else {
            // normal GROUP BY
            newGroups = new SqlNodeList(SqlParserPos.ZERO);
            newGroups.addAll(columnNamesToList(qualification, columns));
          }
          newSelect.setGroupBy(newGroups);
          result = newSelect;
        } else result = null;
      } else {
        result = null;
      }
      if (result == null) return null;
      // return: ... (AS alias)
      return alias == null ? result :
              new SqlBasicCall(new SqlAsOperator(), List.of(result, alias), SqlParserPos.ZERO);
    });
    try {
      return ast.toSqlString(MysqlSqlDialect.DEFAULT).getSql()
              .replace("\n", " ").replace("\r", " ").replace("`", "");
    } catch (AssertionError | IndexOutOfBoundsException e) {
      return null;
    }
  }
}
