package sqlsolver.verifier.runner;

import sqlsolver.api.entry.Verification;
import sqlsolver.common.utils.Args;
import sqlsolver.common.utils.Muter;
import sqlsolver.superopt.logic.VerificationResult;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

public class QueryVerifier implements Runner {
  private static final String CALCITE_APP_NAME = "calcite_test";

  private Path out;
  private Path testCases;
  private int targetPairId;
  private List<Integer> skipPairIds;
  private int rounds = 5;
  private boolean time, tsvNeq;
  private String schema;

  private Path tsvFilePath;
  private StringBuilder tsvStrBuilder;
  private long thisTime; // last case time

  @Override
  public void prepare(String[] argStrings) throws IOException {
    final Args args = Args.parse(argStrings, 1);
    final Path dataDir = RunnerSupport.dataDir();
    time = args.getOptional("time", boolean.class, false);
    String tsvFilename = args.getOptional("tsv", String.class, "tmp_result.tsv");
    tsvFilePath = Path.of(tsvFilename);
    tsvStrBuilder = new StringBuilder();
    tsvNeq = args.getOptional("tsv_neq", boolean.class, false);

    testCases = Path.of(args.getOptional("i", "cases", String.class, "sqlsolver_data/calcite/calcite_tests"));
    final String appName = args.getOptional("A", "app", String.class, CALCITE_APP_NAME);
    schema = Files.readString(dataDir.resolve("schemas").resolve(appName + ".base.schema.sql"));
    // verbose = args.getOptional("v", "verbose", boolean.class, false);

    if (!Files.exists(testCases)) throw new IllegalArgumentException("no such file: " + testCases);

    targetPairId = args.getOptional("target", Integer.class, -1);
    String skipStr = args.getOptional("skip", String.class, "");
    skipPairIds = Arrays.stream(skipStr.split(","))
            .filter(s -> !s.isBlank())
            .map(Integer::valueOf)
            .toList();
    rounds = args.getOptional("rounds", Integer.class, 5);
    if (rounds <= 0) {
      throw new IllegalArgumentException("rounds should be positive");
    }
  }

  // 1=pass, 0=fail, -1=silent_fail
  // collect the result
  private void caseResult(int caseId, int result, long thisTime,
                          HashMap<String, List<Integer>> statistics) {
    if (result != 1) {
      if (result == 0) {
        if (time)
          System.out.println("Case " + caseId + " is: " + "NEQ " + thisTime + " ms");
        else
          System.out.println("Case " + caseId + " is: " + "NEQ");
      }
      statistics.computeIfAbsent("NEQ", k -> new ArrayList<>()).add(caseId);
    } else {
      if (time)
        System.out.println("Case " + caseId + " is: " + "EQ " + thisTime + " ms");
      else
        System.out.println("Case " + caseId + " is: " + "EQ");
      statistics.computeIfAbsent("EQ", k -> new ArrayList<>()).add(caseId);
    }
    if (time) {
      // only output .tsv when -time is set
      if (result == 1 || tsvNeq)
        tsvStrBuilder.append(thisTime);
      tsvStrBuilder.append('\n');
    }
  }

  // 1=pass, 0=fail
  // verify a pair once
  private int verifyPair(String sql0, String sql1) {
    final boolean verbose = false;
    if (verbose) System.out.println(sql0 + "\n" + sql1);


    long millis_before = System.currentTimeMillis();
    final VerificationResult res =
            Verification.verify(sql0, sql1, schema);
    long millis_after = System.currentTimeMillis();
    thisTime += millis_after - millis_before;
    if (res == VerificationResult.EQ) {
      return 1;
    }

    return 0;
  }

  @Override
  public void run() throws Exception {
    long totalTime = 0; // EQ & NEQ cases time
    long totalTimeEQ = 0; // EQ cases time
    List<Long> timeEqCases = new ArrayList<>(); // running time of each EQ case
    final List<String> sqls = Files.readAllLines(testCases);
    final int targetId = targetPairId;
    final HashMap<String, List<Integer>> statistics = new HashMap<>();
    statistics.put("EQ", new ArrayList<>());
    statistics.put("NEQ", new ArrayList<>());
    final Set<Integer> blacklist = new HashSet<>(skipPairIds);
    for (int i = 0, bound = sqls.size(); i < bound; i += 2) {
      int pairId = (i >> 1) + 1;
      if (targetId > 0 && pairId != targetId) continue;
      if (blacklist.contains(pairId)) {
        if (time) tsvStrBuilder.append('\n');
        continue;
      }

      final String sql0 = sqls.get(i), sql1 = sqls.get(i + 1);
      thisTime = 0;
      int ret = verifyPair(sql0, sql1);
      if (time) {
        if (ret == 1 || tsvNeq) {
          // thisTime will accumulate, and at last we take average
          for (int j = 1; j < rounds; j++) {
            verifyPair(sql0, sql1);
          }
          thisTime /= rounds;
        }
        if (ret == 1) {
          totalTimeEQ += thisTime;
          timeEqCases.add(thisTime);
        }
        totalTime += thisTime;
      }
      caseResult(pairId, ret, thisTime, statistics);

    }

    // output .tsv
    if (time) Files.writeString(tsvFilePath, tsvStrBuilder);

    // find median
    final int eqCount = statistics.get("EQ").size();
    long medianEQ = 0;
    if (time) {
      timeEqCases.sort(Long::compare);
      if (eqCount == 0)
        medianEQ = -1;
      else if (eqCount % 2 == 0)
        medianEQ = (timeEqCases.get(eqCount / 2) + timeEqCases.get(eqCount / 2 - 1)) / 2;
      else
        medianEQ = timeEqCases.get(eqCount / 2);
    }

    for (Map.Entry<String, List<Integer>> entry : statistics.entrySet()) {
      System.out.println(entry.getKey() + ": " + entry.getValue().size());
      System.out.println(entry.getValue() + "\n");
    }

    /*if (time) {
      System.out.println("Total time (millisecond): " + totalTime);
      if (eqCount > 0) {
        System.out.println("Total time of passed cases (millisecond): " + totalTimeEQ);
        System.out.println("Average time of passed cases (millisecond): " + totalTimeEQ / eqCount);
        System.out.println("Median time of passed cases (millisecond): " + medianEQ);
      }
    }*/
    System.out.println("Passed " + eqCount + " cases.");
  }

}
