package sqlsolver.verifier.plan.symbolsql2sql.query;

import static sqlsolver.sql.calcite.CalciteSupport.*;
import static sqlsolver.verifier.plan.symbolsql2sql.util.SqlNodeSupport.matchOnce;

import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.calcite.jdbc.CalciteSchema;
import org.apache.calcite.sql.SqlBasicCall;
import org.apache.calcite.sql.SqlNode;
import org.apache.calcite.tools.Planner;
import sqlsolver.sql.calcite.CalciteSupport;

public class QueryValidityChecker {
  public static boolean check(String query, String schema) {
    USER_DEFINED_FUNCTIONS.clear();
    addUserDefinedFunctions(List.of(query));
    try {
      final CalciteSchema calciteSchema = getCalciteSchema(schema);
      final Planner planner = getPlanner(calciteSchema);
      final SqlNode ast = parseAST(query, planner);
      if (ast == null || !checkAST(ast)) return false;
      return parseRel(ast, planner) != null;
    } catch (Throwable e) {
      return false;
    }
  }

  private static boolean checkAST(SqlNode ast) {
    final AtomicBoolean isValid = new AtomicBoolean(true);
    matchOnce(ast, node -> {
      if (node instanceof SqlBasicCall call) {
        if (CalciteSupport.isAggOperator(call.getOperator())
                && call.operandCount() > 1) {
          // agg(...) does not accept multiple arguments
          isValid.set(false);
          return true;
        }
      }
      return false;
    });
    return isValid.get();
  }
}
