package Entry;

import org.apache.calcite.plan.RelOptUtil;
import org.apache.calcite.rel.RelNode;

import com.google.gson.JsonObject;
import com.microsoft.z3.Context;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import AlgeNode.AlgeNode;
import AlgeNodeParser.AlgeNodeParserPair;
import AlgeRule.AlgeRule;

public class simpleTest {
    private static final int ROUNDS = 1;

    private static String case_ = "";

    public static void main(String[] args) throws IOException {
        // load options
        Path testCases = Paths.get(args[0]);
        boolean time = false;
        String tsvFilename = "tmp_result.tsv";
        for (String arg : args) {
            if (arg.startsWith("-time=")) {
                time = arg.equals("-time=True");
            } else if (arg.startsWith("-tsv=")) {
                tsvFilename = arg.substring(5);
            } else if (arg.startsWith("-case=")) {
                case_ = arg.substring(6);
            }
        }
        // System.out.println("-case= " + case_);
        Path tsvFilePath = Paths.get(tsvFilename);
        // prepare
        long trueTime = 0;
        int trueCount = 0;
        int caseCount = 0;
        List<Long> timeEqCases = new ArrayList<>();
        long totalTime = 0;
        StringBuilder tsvStrBuilder = new StringBuilder();
        if (!Files.exists(testCases)) throw new IllegalArgumentException("no such file: " + testCases);
        List<String> sqls = Files.readAllLines(testCases);
        assert sqls.size() % 2 == 0;
        // verify
        for (int i = 0; i < sqls.size(); i += 2) {
            caseCount += 1;
            String q1 = sqls.get(i);
            String q2 = sqls.get(i + 1);
            long millis_before = System.currentTimeMillis();
            JsonObject result = verify(q1, q2);
            long millis_after = System.currentTimeMillis();
            long thisTime = millis_after - millis_before;

            if (result.get("decision").getAsString().equals("true")) {
                if (time) {
                    for (int j = 1; j < ROUNDS; j++) {
                        millis_before = System.currentTimeMillis();
                        verify(q1, q2);
                        millis_after = System.currentTimeMillis();
                        thisTime += millis_after - millis_before;
                    }
                    thisTime /= ROUNDS;
                    trueTime += thisTime;
                    timeEqCases.add(thisTime);
                    tsvStrBuilder.append(thisTime);
                }
                if (time)
                    System.out.println("case " + caseCount + " pass: " + thisTime + " ms");
                else
                    System.out.println("case " + caseCount + " pass");
                trueCount += 1;
            } else {
                System.out.println("case " + caseCount + " fail");
            }
            if (time) {
                tsvStrBuilder.append('\n');
            }
            totalTime += thisTime;
        }

        // output .tsv
        try {
            if (time)
                Files.write(tsvFilePath, tsvStrBuilder.toString().getBytes());
        } catch (Exception e) {
            e.printStackTrace();
        }

        // find median
        int eqCount = trueCount;
        long medianEQ = 0;
        if (time) {
            timeEqCases.sort(Long::compare);
            if (eqCount % 2 == 0)
                medianEQ = (timeEqCases.get(eqCount / 2) + timeEqCases.get(eqCount / 2 - 1)) / 2;
            else
                medianEQ = timeEqCases.get(eqCount / 2);
        }

        /*if (time) {
            System.out.println("Total time (millisecond): " + totalTime);
            System.out.println("Total time of passed cases (millisecond): " + trueTime);
            System.out.println("Average time of passed cases (millisecond): " + trueTime / trueCount);
            System.out.println("Median time of passed cases (millisecond): " + medianEQ);
        }*/
        System.out.println("Passed " + trueCount + " cases.");
    }


    public static JsonObject verify(String sql1, String sql2) {
        JsonObject result = new JsonObject();
        if ((contains(sql1)) || (contains(sql2))) {
            result.addProperty("decision", "unknown");
            result.addProperty("reason", "sql feature not support");
            return result;
        }
        simpleParser parser = new simpleParser(case_);
        simpleParser parser2 = new simpleParser(case_);
        RelNode logicPlan = null;
        RelNode logicPlan2 = null;
        try {
            logicPlan = parser.getRelNode(sql1);
            logicPlan2 = parser2.getRelNode(sql2);
        } catch (Throwable e) {
            result.addProperty("decision", "unknown");
            result.addProperty("reason", "syntax error in sql");
            return result;
        }
//        System.out.println(RelOptUtil.toString(logicPlan));
//        System.out.println(RelOptUtil.toString(logicPlan2));
        AlgeNode algeExpr = null;
        AlgeNode algeExpr2 = null;
        try {
            // System.out.println(RelOptUtil.toString(logicPlan));
            // System.out.println(RelOptUtil.toString(logicPlan2));
            Context z3Context = new Context();
            algeExpr = AlgeRule.normalize(AlgeNodeParserPair.constructAlgeNode(logicPlan, z3Context));
            algeExpr2 = AlgeRule.normalize(AlgeNodeParserPair.constructAlgeNode(logicPlan2, z3Context));
        } catch (Exception e) {
            result.addProperty("decision", "unknown");
            result.addProperty("reason", "sql feature not support");
            return result;
        }
        try {
            if (algeExpr.isEq(algeExpr2)) {
                result.addProperty("decision", "true");
            } else {
                result.addProperty("decision", "false");
            }
            result.addProperty("plan1", RelOptUtil.toString(logicPlan));
            result.addProperty("plan2", RelOptUtil.toString(logicPlan2));
        } catch (Exception e) {
            result.addProperty("decision", "unknown");
            result.addProperty("reason", "unknown");
        } finally {
            return result;
        }
    }

    static public boolean contains(String sql) {
        String[] keyWords = {"VALUE", "EXISTS", "ROW", "ORDER", "CAST", "INTERSECT", "EXCEPT", " IN "};
        for (String keyWord : keyWords) {
            if (sql.contains(keyWord)) {
                return true;
            }
        }
        return false;
    }
}

