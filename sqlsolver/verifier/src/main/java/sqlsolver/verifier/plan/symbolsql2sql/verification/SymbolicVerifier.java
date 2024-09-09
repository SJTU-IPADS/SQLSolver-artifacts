package sqlsolver.verifier.plan.symbolsql2sql.verification;

import java.util.*;

import org.apache.calcite.sql.parser.SqlParseException;
import sqlsolver.api.entry.Verification;
import sqlsolver.common.config.GlobalConfig;
import sqlsolver.superopt.logic.VerificationResult;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.ConstraintLoader;
import sqlsolver.verifier.plan.symbolsql2sql.util.ConcreteQuerySchemaProducer;

public class SymbolicVerifier {
  /**
   * Given a rule (two queries and constraints),
   * try to relax constraints while preserving
   * equivalence of two symbolic queries w.r.t. constraints.
   * @return which category the rule belongs to,
   *   and a set of constraint sets after relaxation if the rule is correct
   */
  public SymbolicSqlRuleResult relaxAndVerify(String symbolicQuery0, String symbolicQuery1, String constraintsStr) {
    // load constraints
    final ConstraintLoader constraintLoader = new ConstraintLoader();
    final List<Constraint> constraints = constraintLoader.load(constraintsStr);
    return relaxAndVerify(symbolicQuery0, symbolicQuery1, constraints);
  }

  /**
   * Judge whether a rule is correct
   * by verifying equivalence of queries w.r.t. the specified schema.
   * The symbolic queries should adhere to the following requirements:
   * <ul>
   *     <li>Table/subquery aliases must be unique within the rule.</li>
   *     <li>Other symbols should not be in those forms.</li>
   *     <li>The first argument of an "AttrsSub" constraint should be an attribute list.</li>
   *     <li>The second argument of an "AttrsSub" constraint should be a subquery alias or a table.</li>
   * </ul>
   */
  public SymbolicSqlRuleResult.Category verify(String symbolicQuery0, String symbolicQuery1, List<Constraint> constraints) {
    // Enumerate possible concrete query pairs.
    if (GlobalConfig.LOG_LEVEL >= 2) {
      System.out.println("Symbolic SQL0: " + symbolicQuery0);
      System.out.println("Symbolic SQL1: " + symbolicQuery1);
      System.out.println("Constraints: " + constraints);
    }
    final ConcreteQuerySchemaProducer producer = new ConcreteQuerySchemaProducer();
    final List<String[]> concretePairs;
    try {
      concretePairs = producer.produce(symbolicQuery0, symbolicQuery1, constraints);
    } catch (SqlParseException e) {
      return SymbolicSqlRuleResult.Category.INCORRECT;
    }
    // Verify concrete query pairs.
    // The original symbolic queries are equivalent
    // iff they produce at least one pair of valid concrete queries
    // and each pair of valid concrete queries they produce are equivalent.
    int count = 0;
    for (String[] pair : concretePairs) {
      count++;
      if (GlobalConfig.LOG_LEVEL >= 2) {
        System.out.println("SQL" + count + "-0: " + pair[0]);
        System.out.println("SQL" + count + "-1: " + pair[1]);
        System.out.println("Schema: " + pair[2]);
      }
      if (!concreteVerify(pair[0], pair[1], pair[2])) {
        if (GlobalConfig.LOG_LEVEL >= 1) {
          System.out.println("Incorrect rule.");
        }
        return SymbolicSqlRuleResult.Category.INCORRECT;
      }
    }
    if (concretePairs.isEmpty()) {
      if (GlobalConfig.LOG_LEVEL >= 1) {
        System.out.println("Invalid rule.");
      }
      return SymbolicSqlRuleResult.Category.INCORRECT;
    }
    return SymbolicSqlRuleResult.Category.CORRECT;
  }

  /**
   * Similar to {@link #relaxAndVerify(String, String, String)}}
   * except that constraints have already been parsed into a list.
   */
  private SymbolicSqlRuleResult relaxAndVerify(String symbolicQuery0, String symbolicQuery1, List<Constraint> constraints) {
    SymbolicSqlRuleResult.Category category = SymbolicSqlRuleResult.Category.INCORRECT;
    try {
      category = verify(symbolicQuery0, symbolicQuery1, constraints);
    } catch (Throwable e) {
      System.err.println("Verification error: " + e.getMessage());
    }
    // incorrect result
    if (category == SymbolicSqlRuleResult.Category.INCORRECT)
      return SymbolicSqlRuleResult.mkIncorrect();
    // try removing each constraint
    final Set<Set<Constraint>> minimals = new HashSet<>();
    for (int i = 0, bound = constraints.size(); i < bound; i++) {
      final Constraint constraint = constraints.get(i);
      // AttrsSub constraints are not removed
      if (constraint.type() == Constraint.Type.ATTRS_SUB) {
        continue;
      }
      // remove the constraint
      final List<Constraint> newConstraints = new ArrayList<>(constraints);
      newConstraints.remove(i);
      // try verification recursively
      final SymbolicSqlRuleResult newMinimals = relaxAndVerify(symbolicQuery0, symbolicQuery1, newConstraints);
      if (newMinimals.category() == SymbolicSqlRuleResult.Category.CORRECT) {
        minimals.addAll(newMinimals.constraintSets());
      }
    }
    if (minimals.isEmpty()) minimals.add(new LinkedHashSet<>(constraints));
    return SymbolicSqlRuleResult.mkCorrect(minimals);
  }

  private boolean concreteVerify(String query0, String query1, String schema) {
    switch (GlobalConfig.VERIFIER) {
      case GlobalConfig.VERIFIER_SQLSOLVER -> {
        return Verification.verify(query0, query1, schema, GlobalConfig.VERIFIER_TIMEOUT) == VerificationResult.EQ;
      }
    }
    throw new UnsupportedOperationException("unsupported verifier: " + GlobalConfig.VERIFIER);
  }
}
