package sqlsolver.verifier.plan;

import org.apache.calcite.sql.SqlNode;
import org.apache.calcite.sql.parser.SqlParseException;
import org.apache.calcite.tools.Planner;
import org.junit.jupiter.api.Test;
import sqlsolver.common.config.GlobalConfig;
import sqlsolver.common.utils.Muter;
import sqlsolver.sql.calcite.CalciteSupport;
import sqlsolver.superopt.substitution.Substitution;
import sqlsolver.superopt.substitution.SubstitutionBank;
import sqlsolver.superopt.substitution.SubstitutionSupport;
import sqlsolver.verifier.plan.rule2symbolsql.RequestGenerator;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.ConstraintLoader;
import sqlsolver.verifier.plan.symbolsql2sql.util.ConcreteQuerySchemaProducer;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicSqlRuleResult;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicVerifier;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.io.*;
import java.util.List;

import static sqlsolver.common.io.FileUtils.dataDir;
import static sqlsolver.common.utils.ListSupport.map;

public class RuleVerifierTest {


  private void testRulesFromFile(Path ruleFilePath) throws IOException {
    final SubstitutionBank rules = SubstitutionSupport.loadBank(ruleFilePath);
    int count = 0;
    for (Substitution rule : rules.rules()) {
      System.out.println("Verifying rule " + (++count));
      final RuleVerifier verifier = new RuleVerifier();
      final boolean result = verifier.verify(rule);
      System.out.println("Rule " + count + ": " + result);
    }
  }

  private void testRulesFromFileSymbolicOnly(Path ruleFilePath) throws IOException {
    final SubstitutionBank rules = SubstitutionSupport.loadBank(ruleFilePath);
    int count = 0;
    for (Substitution rule : rules.rules()) {
      final RequestGenerator generator = new RequestGenerator(rule, false);
      final String[] request = generator.translate();

      // verify
      final String srcSQL = request[0];
      final String dstSQL = request[1];
      final String constraintStr = request[2];
      System.out.println("Translating rule " + (++count));
      System.out.println("srcSQL: " + srcSQL);
      System.out.println("dstSQL: " + dstSQL);
      System.out.println("constraintStr: " + constraintStr);
    }
  }

  @Test
  public void testSingleRulesSymbolicOnly() throws IOException {
    final Path ruleFilePath = dataDir().resolve("prepared").resolve("rules.debug.txt");
    testRulesFromFileSymbolicOnly(ruleFilePath);
  }

  @Test //test symbolic sql using calcite parser
  public void testSymbolicParseOnly() throws IOException {
    final Path ruleFilePath = dataDir().resolve("prepared").resolve("rules.symbolic.txt");
    final List<String> lines = Files.readAllLines(ruleFilePath);
    final int totalLines=lines.size();
    int ln=0;
    while(ln<totalLines){
      String symbolicQuery=lines.get(ln++);
      try{
        final Planner parser = CalciteSupport.getParser();
        final SqlNode ast0 = parser.parse(symbolicQuery);
        parser.close();
        //System.out.println("Correct: "+ln);
      }
      catch (SqlParseException e){
        System.out.println("# Parse Failure at: "+ln);
        e.printStackTrace();
      }
    }
    System.out.println("Test Done");
  }

  @Test //given (symSQL0,symSQL1,constraints) , call produce to get concrete schema
  public void testSymbolicToSchema() throws IOException {
    final Path ruleFilePath = dataDir().resolve("prepared").resolve("rules.produce.txt");
    final List<String> lines = Files.readAllLines(ruleFilePath);
    final int totalLines=lines.size();
    int ln=0;
    while(ln<totalLines){
        String symbolicQuery0=lines.get(ln++);
        String symbolicQuery1=lines.get(ln++);
        String conStr=lines.get(ln++);
        final List<Constraint> constraints = new ConstraintLoader().load(conStr);
        final ConcreteQuerySchemaProducer producer = new ConcreteQuerySchemaProducer();
        final List<String[]> concretePairs;
        try{
          concretePairs = producer.produce(symbolicQuery0, symbolicQuery1, constraints);
          System.out.println("# Group: "+(ln/3));
          for (String[] pair : concretePairs) {
            System.out.println(pair[0]);
            System.out.println(pair[1]);
            System.out.println(pair[2]);
          }
        }
        catch (Exception e){
          System.out.println("# Produce Failure at: "+(ln/3));
          e.printStackTrace();
        }
    }
    System.out.println("Test Done");
  }

  /**
   * Test the verifier on 35 useful rules from WeTune.
   */
  @Test
  public void testSingleRules() throws IOException {
    final Path ruleFilePath = dataDir().resolve("prepared").resolve("rules.sqlsolver.txt");
    testRulesFromFile(ruleFilePath);
  }

  @Test
  public void testRuleToSql() throws IOException {
    final Path ruleFilePath = dataDir().resolve("prepared").resolve("rules.sqlsolver.txt");
    final SubstitutionBank rules = SubstitutionSupport.loadBank(ruleFilePath);
    int targetId = 33;
    for (Substitution rule : rules.rules()) {
      if (targetId > 0 && rule.id() != targetId) continue;
      System.out.println(rule.id());
      System.out.println(rule);
      try {
        RequestGenerator requestGenerator = new RequestGenerator(rule, false);
        String[] result = requestGenerator.translate();
        System.out.println(result[0]);
        System.out.println(result[1]);
        System.out.println(result[2]);
        System.out.println("\n\n\n");
        final List<Constraint> constraints = new ConstraintLoader().load(result[2]);
        SymbolicSqlRuleResult.Category flag;
        final SymbolicVerifier verifier = new SymbolicVerifier();
        flag = verifier.verify(result[0], result[1], constraints);
//    } else {
//      result = Muter.mute(() -> verifier.verify(srcSQL, dstSQL, constraints));
//    }
        if (flag == SymbolicSqlRuleResult.Category.CORRECT) {
          System.out.println("true");
        } else if (flag == SymbolicSqlRuleResult.Category.INCORRECT) {
          System.out.println("false");
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  @Test
  public void testSymVerifier() {
    final SymbolicVerifier verifier = new SymbolicVerifier();
    final String srcSQL = "(select * from (select r1.a2, count( distinct r1.a3) as a4 from ((select * from (select distinct r2.a0 from r2 as r2) as r4) union (select * from (select distinct r3.a0 from r2 as r3) as r5)) as r1 group by r1.a2 having p0(a4)) as r6)";
    final String dstSQL = "(select * from (select r8.a2, count( distinct r8.a3) as a4 from (select r7.a0 from r2 as r7) as r8 group by r8.a2 having p0(a4)) as r9)";
    final String constraintStr = "AttrsSub(a0,r2);AttrsSub(a2,r4);AttrsSub(a3,r4);AttrsSub(a4,r6);NotNull(r2,a3);";
    final List<Constraint> constraints = new ConstraintLoader().load(constraintStr);
    final SymbolicSqlRuleResult.Category result;
//    if (GlobalConfig.LOG_LEVEL >= 1) {
      result = verifier.verify(srcSQL, dstSQL, constraints);
//    } else {
//      result = Muter.mute(() -> verifier.verify(srcSQL, dstSQL, constraints));
//    }
    if (result == SymbolicSqlRuleResult.Category.CORRECT) {
      System.out.println("true");
    } else if (result == SymbolicSqlRuleResult.Category.INCORRECT) {
      System.out.println("false");
    }
  }

  @Test
  public void testCalciteParse() {
//    (INNER_JOIN), (LEFT_JOIN),
//    SIMPLE_FILTER,
//    (PROJ_SIMPLE),
//    (AGG_SUM, AGG_AVERAGE, AGG_COUNT, AGG_MAX),
//    UNION, UNION_ALL,
//    IN_SUB_FILTER, EXISTS_FILTER,
    String[] queries = {
            "SELECT e.name, d.department_name FROM employees e JOIN departments d ON e.dept_id = d.dept_id WHERE e.salary > 50000",
            "SELECT a FROM table1 as alias",
            "SELECT f(a) FROM table1",
            "SELECT SUM(salary) FROM employees",
            "SELECT col1 FROM table1 UNION ALL SELECT col2 FROM table2",
            "SELECT * FROM employees WHERE EXISTS (SELECT * FROM departments WHERE dept_id = employees.dept_id)",
            "SELECT * FROM employees WHERE dept_id IN (SELECT dept_id FROM departments)"
    };
    for (String query : queries) {
      try {
        final Planner parser = CalciteSupport.getParser();
        final SqlNode ast0 = parser.parse(query);
        System.out.println("Parsing query: " + query);
      } catch (SqlParseException e) {
        e.printStackTrace();
      }
    }
  }
}
