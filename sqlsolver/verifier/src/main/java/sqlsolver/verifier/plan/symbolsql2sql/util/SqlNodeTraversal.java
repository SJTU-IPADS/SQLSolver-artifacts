package sqlsolver.verifier.plan.symbolsql2sql.util;

import java.util.List;
import org.apache.calcite.sql.*;
import org.apache.calcite.sql.fun.SqlCase;
import org.apache.calcite.sql.parser.SqlParserPos;

/**
 * <p>
 * A traversal that explores and replaces sub-nodes
 * (e.g. sub-queries, sub-expressions)
 * of a query node recursively.
 * </p>
 */
public abstract class SqlNodeTraversal {

  private final boolean allowsMultipleApplications;
  private int applicationCount;

  /**
   * Create a traversal object.
   * @param allowsMultipleApplications
   * whether the method {@link #handleNode} can be successfully applied multiple times.
   */
  public SqlNodeTraversal(boolean allowsMultipleApplications) {
    this.allowsMultipleApplications = allowsMultipleApplications;
    applicationCount = 0;
  }

  /**
   * Handle the sub-node in the current level.
   * It may return a new sub-node for substitution;
   * otherwise it should return {@code null}.
   * Recursion is handled by this class, so this method does not need to do recursion.
   * @param node the sub-node to be handled
   * @return the substituted node, or {@code null} indicating that the method is not successfully applied
   */
  public abstract SqlNode handleNode(SqlNode node);

  public final SqlNode traverse(SqlNode node) {
    return traverse0(node);
  }

  private SqlNode traverse0(SqlNode node) {
    if (node == null) return null;
    if (!allowsMultipleApplications && applicationCount > 0) {
      // the desired rewrite has been performed
      return node;
    }
    // current-level replacement
    SqlNode newExpr = handleNode(node);
    if (newExpr == null) {
      // not successful; do not count
      newExpr = node;
    } else {
      applicationCount++;
    }
    // recursion
    if (newExpr instanceof SqlSelect select) {
      final SqlSelect newSelect = (SqlSelect) select.clone(SqlParserPos.ZERO);
      // handle SELECT list
      final SqlNodeList items = select.getSelectList();
      newSelect.setSelectList((SqlNodeList) traverse0(items));
      // handle FROM
      newSelect.setFrom(traverse0(select.getFrom()));
      // handle WHERE
      newSelect.setWhere(traverse0(select.getWhere()));
      // handle groupBy
      final SqlNodeList groups = select.getGroup();
      newSelect.setGroupBy((SqlNodeList) traverse0(groups));
      // handle HAVING
      newSelect.setHaving(traverse0(select.getHaving()));
      return newSelect;
    } else if (newExpr instanceof SqlOrderBy orderBy) {
      final SqlNodeList orderList = orderBy.orderList;
      for (int i = 0; i < orderList.size(); i++) {
        SqlNode item = orderList.get(i);
        SqlNode newItem = traverse0(item);
        if (newItem != item) {
          orderList.set(i, newItem);
        }
      }

      SqlNode offset = orderBy.offset;
      if (offset != null) {
        offset = traverse(offset);
      }

      SqlNode fetch = orderBy.fetch;
      if (fetch != null) {
        fetch = traverse(fetch);
      }

      // rebuild SqlOrderBy
      return new SqlOrderBy(SqlParserPos.ZERO, traverse0(orderBy.query), orderList, offset, fetch);
    } else if (newExpr instanceof SqlBasicCall call) {
      final SqlBasicCall newCall = (SqlBasicCall) call.clone(SqlParserPos.ZERO);
      // normal recursion
      List<SqlNode> args = call.getOperandList();
      for (int i = 0; i < args.size(); i++) {
        newCall.setOperand(i, traverse0(args.get(i)));
      }
      return newCall;
    } else if (newExpr instanceof SqlCase cas) {
      final SqlCase newCase = (SqlCase) cas.clone(SqlParserPos.ZERO);
      final SqlNodeList whens = cas.getWhenOperands();
      final SqlNodeList newWhens = newCase.getWhenOperands();
      for (int i = 0; i < whens.size(); i++) {
        newWhens.set(i, traverse0(whens.get(i)));
      }
      final SqlNodeList thens = cas.getThenOperands();
      final SqlNodeList newThens = newCase.getThenOperands();
      for (int i = 0; i < thens.size(); i++) {
        newThens.set(i, traverse0(thens.get(i)));
      }
      newCase.setOperand(3, cas.getElseOperand());
      return newCase;
    } else if (newExpr instanceof SqlJoin join) {
      // SqlJoin
      return new SqlJoin(SqlParserPos.ZERO, traverse0(join.getLeft()),
              join.isNaturalNode(), join.getJoinTypeNode(),
              traverse0(join.getRight()), join.getConditionTypeNode(),
              traverse0(join.getCondition()));
    } else if (newExpr instanceof SqlNodeList items) {
      final SqlNodeList newItems = items.clone(SqlParserPos.ZERO);
      for (int i = 0; i < items.size(); i++) {
        SqlNode item = items.get(i);
        SqlNode newItem = traverse0(item);
        if (newItem != item) {
          newItems.set(i, newItem);
        }
      }
      return newItems;
    }
    return newExpr;
  }

}
