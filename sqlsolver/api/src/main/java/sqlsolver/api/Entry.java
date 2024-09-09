package sqlsolver.api;

import sqlsolver.api.entry.Verification;
import sqlsolver.common.utils.Args;
import sqlsolver.common.utils.Muter;
import sqlsolver.superopt.logic.LogicSupport;
import sqlsolver.superopt.logic.VerificationResult;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class Entry {
  public static void main(String[] argStrings) {
    /*
     * There should be at least three arguments:
     * -sql1 indicates the first sql file; its alternative -sql1str specifies the first sql and overrides this argument.
     * -sql2 indicates the second sql file; its alternative -sql2str specifies the second sql and overrides this argument.
     * -schema indicates the schema file; its alternative -schemastr specifies the schema and overrides this argument.
     * [-timeout] indicates an intended upper bound of verification time of every sql pair.
     * [-print] indicates whether print the result to standard output stream.
     * [-output] indicates where to store the verification result.
     * [-help] indicates that show all the arguments.
     * Each SQL statement in the SQL file should be on a separate line.
     * The SQL statements on the same lines in two SQL files
     * are the two SQL statements that need to be verified for equivalence.
     */
    final Args args = Args.parse(argStrings, 0);

    final String firstQueryPathString = args.getOptional("sql1", String.class, null);
    final String secondQueryPathString = args.getOptional("sql2", String.class, null);
    final String schemaPathString = args.getOptional("schema", String.class, null);

    // string arguments override file path arguments
    final String firstQueryString = args.getOptional("sql1str", String.class, null);
    final String secondQueryString = args.getOptional("sql2str", String.class, null);
    final String schemaString = args.getOptional("schemastr", String.class, null);

    final Integer timeout = args.getOptional("timeout", Integer.class, -1);
    final Boolean print = args.getOptional("print", Boolean.class, false);
    final Boolean help = args.getOptional("help", Boolean.class, false);
    final String outputPathString = args.getOptional("output", String.class, null);

    if (help) {
      String helpText = """
              java -jar sqlsolver.jar [-help] -sql1=<path/to/query1> -sql2=<path/to/query2> -schema=<path/to/schema>
                                              -sql1str=<query1> -sql2str=<query2> -schemastr=<schema>
                                      [-timeout=<timeout>] [-print] [-output=<path/to/output>]

              Options:
                -help                    Show this help message and exit.
                -sql1=<path/to/query1>   The first sql file.
                -sql2=<path/to/query2>   The second sql file.
                -schema=<path/to/schema> The schema file.
                -sql1str=<query1>        The first sql as a string. It overrides the argument "-sql1".
                -sql2str=<query2>        The second sql as a string. It overrides the argument "-sql2".
                -schemastr=<schema>      The schema as a string. It overrides the argument "-schema".
                -timeout                 The intended upper bound of verification time of each SQL pair in seconds.
                -print                   Print the result to standard output stream.
                -output=<path/to/output> The file that store the verification result.
              """;
      System.out.println(helpText);
      return;
    }

    final List<VerificationResult> results = Muter.mute(() -> run(
            firstQueryString, firstQueryPathString,
            secondQueryString, secondQueryPathString,
            schemaString, schemaPathString,
            timeout));

    // print it through STDOUT
    if (print) {
      System.out.println(results);
    }

    // output result into the target file
    if (outputPathString != null) {
      try (FileWriter fileWriter = new FileWriter(outputPathString)) {
        for (VerificationResult result : results)
          fileWriter.append(result.toString()).append("\n");
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  /** A wrapper of loading data and verification. */
  private static List<VerificationResult> run(String firstQueryString, String firstQueryPathString,
                                              String secondQueryString, String secondQueryPathString,
                                              String schemaString, String schemaPathString,
                                              int timeout) {
    // load the queries and schema
    // string arguments are of higher precedence
    final List<String> firstQueries = readStringListOrFile(firstQueryString, firstQueryPathString,
            "missing the first sql file: -sql1=<path/to/query1>" +
                    "or the first sql as a string: -sql1str=<query1>");
    final List<String> secondQueries = readStringListOrFile(secondQueryString, secondQueryPathString,
            "missing the second sql file: -sql2=<path/to/query2>" +
                    "or the second sql as a string: -sql2str=<query2>");
    final String schema = readStringOrFile(schemaString, schemaPathString,
            "missing the schema file: -schema=<path/to/schema>" +
                    "or the schema as a string: -schemastr=<schema>");
    // verify the equivalence
    return Verification.verify(firstQueries, secondQueries, schema, timeout);
  }

  /**
   * If "string" is not null, return a singleton list of "string".
   * If "pathString" is not null, read a list of strings from the file it specifies;
   * it prints "hint" and returns null if the I/O operation fails.
   * Otherwise, return null.
   */
  private static List<String> readStringListOrFile(String string, String pathString, String hint) {
    if (string != null) {
      return List.of(string);
    }
    if (pathString == null) {
      System.err.println(hint);
      return null;
    }
    final Path path = Paths.get(pathString);
    try {
      return Files.readAllLines(path);
    } catch (IOException e) {
      System.err.println(hint);
      if (LogicSupport.dumpLiaFormulas)
        e.printStackTrace();
      return null;
    }
  }

  /**
   * Similar to #readStringListOrFile except that this method
   * returns a string instead of a string list.
   */
  private static String readStringOrFile(String string, String pathString, String hint) {
    if (string != null) {
      return string;
    }
    if (pathString == null) {
      System.err.println(hint);
      return null;
    }
    final Path path = Paths.get(pathString);
    try {
      return Files.readString(path);
    } catch (IOException e) {
      System.err.println(hint);
      if (LogicSupport.dumpLiaFormulas)
        e.printStackTrace();
      return null;
    }
  }
}