package sqlsolver.verifier.plan.symbolsql2sql.verification;

import java.util.Set;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;

public record SymbolicSqlRuleResult(Category category, Set<Set<Constraint>> constraintSets) {
  public enum Category {
    CORRECT, INCORRECT
  }

  public static SymbolicSqlRuleResult mkCorrect(Set<Set<Constraint>> constraintSets) {
    return new SymbolicSqlRuleResult(Category.CORRECT, constraintSets);
  }

  public static SymbolicSqlRuleResult mkIncorrect() {
    return new SymbolicSqlRuleResult(Category.INCORRECT, null);
  }
}
