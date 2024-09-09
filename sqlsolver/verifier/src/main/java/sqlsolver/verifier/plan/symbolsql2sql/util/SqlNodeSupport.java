package sqlsolver.verifier.plan.symbolsql2sql.util;

import org.apache.calcite.sql.*;
import org.apache.calcite.sql.parser.SqlParserPos;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;
import java.util.function.Predicate;

public abstract class SqlNodeSupport {
  /**
   * Match sub-nodes in a given node in pre-order.
   * @param node the given node
   * @param filter when applied to a sub-node, its return value indicates whether a sub-node is matched
   * @return the sub-nodes matched
   */
  public static List<SqlNode> match(SqlNode node, Predicate<SqlNode> filter) {
    return match(node, filter, true);
  }

  public static SqlNode matchOnce(SqlNode node, Predicate<SqlNode> filter) {
    final List<SqlNode> list = match(node, filter, false);
    assert list.size() <= 1;
    return list.isEmpty() ? null : list.get(0);
  }

  private static List<SqlNode> match(SqlNode node, Predicate<SqlNode> filter, boolean multipleMatches) {
    final List<SqlNode> matches = new ArrayList<>();
    new SqlNodeTraversal(multipleMatches) {
      @Override
      public SqlNode handleNode(SqlNode node) {
        if (filter.test(node)) {
          matches.add(node);
          return node;
        }
        return null;
      }
    }.traverse(node);
    return matches;
  }

  /**
   * Replace sub-nodes in a given node in pre-order.
   * @param node the given node
   * @param toReplace whether and how to replace a sub-node;
   *                  when applied to a sub-node,
   *                  if it returns <code>null</code>, then the sub-node is not replaced;
   *                  otherwise, the sub-node is replaced with its return value
   * @return the node after replacement
   */
  public static SqlNode replace(SqlNode node, Function<SqlNode, SqlNode> toReplace) {
    return new SqlNodeTraversal(true) {
      @Override
      public SqlNode handleNode(SqlNode node) {
        final SqlNode newNode = toReplace.apply(node);
        return newNode;
      }
    }.traverse(node);
  }

  public static boolean isStar(SqlNode sqlNode) {
    if (sqlNode instanceof SqlIdentifier id) {
      return id.isStar();
    }
    return false;
  }

  public static SqlIdentifier getAlias(SqlNode sqlNode) {
    if (sqlNode instanceof SqlBasicCall call &&
            call.getOperator() instanceof SqlAsOperator) {
      return call.operand(1);
    }
    return null;
  }

  public static SqlNode removeAlias(SqlNode sqlNode) {
    if (sqlNode instanceof SqlBasicCall call &&
            call.getOperator() instanceof SqlAsOperator) {
      return call.operand(0);
    }
    return sqlNode;
  }

  public static String getQualificationString(SqlNode sqlNode) {
    final SqlIdentifier qualificationNode = getQualification(sqlNode);
    return qualificationNode == null ? null : qualificationNode.getSimple();
  }

  public static SqlIdentifier getQualification(SqlNode sqlNode) {
    if (sqlNode instanceof SqlIdentifier id) {
      // only handle things like t.a
      if (id.names.size() != 2) {
        return null;
      }
      return new SqlIdentifier(id.names.get(0), id.getParserPosition());
    }
    return null;
  }

  public static SqlNode removeQualification(SqlNode sqlNode) {
    if (sqlNode instanceof SqlIdentifier id) {
      return new SqlIdentifier(id.names.get(id.names.size() - 1), id.getParserPosition());
    }
    return sqlNode;
  }

  /**
   * Convert concrete columns to a SqlNode list.
   * The given qualification will be added as a prefix before each SqlNode.
   */
  public static List<SqlNode> columnNamesToList(String qualification, List<String> columnNames) {
    final List<SqlNode> result = new ArrayList<>();
    for (String column : columnNames) {
      // for each column "ci", generate a new column "(t.)ci"
      final SqlIdentifier newColumn;
      if (qualification == null)
        newColumn = new SqlIdentifier(column, SqlParserPos.ZERO);
      else
        newColumn = new SqlIdentifier(List.of(qualification, column), SqlParserPos.ZERO);
      result.add(newColumn);
    }
    return result;
  }

  /**
   * Whether ast generates exactly one column
   * (i.e. ast is a (aggregate) function call).
   */
  public static boolean isSingleColumn(SqlNode ast) {
    return ast instanceof SqlBasicCall
            && (ast.getKind().belongsTo(SqlKind.FUNCTION)
            || ast.getKind().belongsTo(SqlKind.AGGREGATE));
  }
}
