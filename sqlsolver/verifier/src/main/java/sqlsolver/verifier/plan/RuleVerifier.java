package sqlsolver.verifier.plan;

import sqlsolver.common.config.GlobalConfig;
import sqlsolver.common.utils.Muter;
import sqlsolver.superopt.substitution.Substitution;
import sqlsolver.verifier.plan.rule2symbolsql.RequestGenerator;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.ConstraintLoader;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicSqlRuleResult;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicVerifier;

import java.util.List;

public class RuleVerifier {
  public boolean verify(Substitution rule) {
    if (GlobalConfig.LOG_LEVEL >= 1) {
      System.out.println("Verifying: " + rule);
    }
    final RequestGenerator generator = new RequestGenerator(rule, false);
    final String[] request = generator.translate();
    final SymbolicVerifier verifier = new SymbolicVerifier();

    // verify
    final String srcSQL = request[0];
    final String dstSQL = request[1];
    final String constraintStr = request[2];
    final List<Constraint> constraints = new ConstraintLoader().load(constraintStr);
    final SymbolicSqlRuleResult.Category result;
    if (GlobalConfig.LOG_LEVEL >= 1) {
      result = verifier.verify(srcSQL, dstSQL, constraints);
    } else {
      result = Muter.mute(() -> verifier.verify(srcSQL, dstSQL, constraints));
    }
    if (result == SymbolicSqlRuleResult.Category.CORRECT) {
      return true;
    } else if (result == SymbolicSqlRuleResult.Category.INCORRECT) {
      return false;
    }

    return false;
  }
}
