package sqlsolver.verifier.plan.verification;

import org.junit.jupiter.api.Test;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.ConstraintLoader;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicSqlRuleResult;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicVerifier;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static sqlsolver.common.io.FileUtils.dataDir;

public class SymbolicVerifierTest {
  /**
   * Test the symbolic SQL verifier on 35 useful rules
   * (except the last 3 with Agg) from WeTune.
   */
  @Test
  public void testSymbolicVerifierOnWeTuneRules() throws IOException {
    final Path ruleFilePath = dataDir().resolve("symbolic").resolve("wetune_rules.txt");
    testSymbolicVerifierRulesFromFile(ruleFilePath);
  }

  /**
   * Test the symbolic SQL verifier on example rules.
   */
  @Test
  public void testSymbolicVerifierOnExampleRules() throws IOException {
    final Path ruleFilePath = dataDir().resolve("symbolic").resolve("example_rules.txt");
    testSymbolicVerifierRulesFromFile(ruleFilePath);
  }

  private void testSymbolicVerifierRulesFromFile(Path ruleFilePath) throws IOException {
    int count = 0;
    for (String line : Files.readAllLines(ruleFilePath)) {
      System.out.println("Verifying symbolic SQL rule " + (++count));
      final String[] request = line.split("\\|");
      final String srcSQL = request[0];
      final String dstSQL = request[1];
      final String constraintStr = request[2];
      final List<Constraint> constraints = new ConstraintLoader().load(constraintStr);
      final SymbolicVerifier verifier = new SymbolicVerifier();
      final SymbolicSqlRuleResult.Category result = verifier.verify(srcSQL, dstSQL, constraints);
      System.out.println("Rule " + count + ": " + result);
    }
  }
}
