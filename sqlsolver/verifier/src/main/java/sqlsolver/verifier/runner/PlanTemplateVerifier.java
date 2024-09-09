package sqlsolver.verifier.runner;

import sqlsolver.common.utils.Args;
import sqlsolver.superopt.substitution.Substitution;
import sqlsolver.superopt.substitution.SubstitutionBank;
import sqlsolver.verifier.plan.RuleVerifier;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

// The entry class of verifying found rules of plan templates
public class PlanTemplateVerifier implements Runner {
  private String testsName;
  private Path filePath;

  @Override
  public void prepare(String[] argStrings) throws Exception {
    final Args args = Args.parse(argStrings, 1);
    // Optional argument:
    // -t TESTS / --tests TESTS
    // Usage: specify the test set TESTS
    // TESTS can be "wetune" / "sqlsolver"
    // by default TESTS="sqlsolver"
    testsName = args.getOptional("t", "tests", String.class, "sqlsolver");
    filePath = RunnerSupport.dataDir().resolve("prepared").resolve("rules." + testsName + ".txt");
  }

  @Override
  public void run() throws Exception {
    // the main method
    // verification is done here
    final List<String> rules = Files.readAllLines(filePath);
    int countEq = 0;
    for (int i = 0, bound = rules.size(); i < bound; i++) {
      int ruleId = i + 1;
      final String rule = rules.get(i);
      final boolean result = verifyRule(rule);
      if (result) {
        countEq++;
      }
      System.out.println("Rule " + ruleId + (result ? ": EQ" : ": NEQ"));
    }
    System.out.println("Passed " + countEq + " rules.");
  }

  private boolean verifyRule(String rule) {
    final RuleVerifier ruleVerifier = new RuleVerifier();
    return ruleVerifier.verify(Substitution.parse(rule));
  }
}
