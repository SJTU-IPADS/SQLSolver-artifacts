package sqlsolver.common.config;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class GlobalConfig {
  /** Z3 timeout used by SQLSolver, in millis. */
  public static final int SQLSOLVER_Z3_TIMEOUT;
  /** Whether IC selection is enabled. If disabled, all ICs are applied in each run. */
  public static final boolean SQLSOLVER_ENABLE_IC_SELECT;
  /** Whether predicates (like IN list) are unfolded if necessary. */
  public static final boolean SQLSOLVER_FOLD_PREDICATES;

  // Constants
  public static final String VERIFIER_SQLSOLVER = "sqlsolver";

  // Configuration keys
  public static final String KEY_LOG_LEVEL = "wetune.enumerator.log-level";
  public static final String KEY_WORKERS = "wetune.enumerator.workers";
  public static final String KEY_VERIFIER_TIMEOUT = "wetune.enumerator.verifier.timeout";
  public static final String KEY_VERIFIER = "sqlsolver.rule.verifier";
  public static final String KEY_USE_HINT = "wetune.enumerator.use-hint";
  public static final String KEY_Z3_TIMEOUT = "sqlsolver.z3.timeout";
  public static final String KEY_ENABLE_IC_SELECT = "sqlsolver.ic-select";
  public static final String KEY_FOLD_PREDICATES = "sqlsolver.fold-predicates";

  // Configuration
  public static final int LOG_LEVEL;
  public static final String VERIFIER;
  public static final int WORKERS;
  public static final String USE_HINT;
  public static final int VERIFIER_TIMEOUT;

  static  {
    Properties properties = new Properties();
    try (FileInputStream fileInputStream = new FileInputStream("sqlsolver.properties")) {
      properties.load(fileInputStream);
    } catch (IOException e) {
      System.err.println("Failed to load the configuration file. SQLSolver will use its defaults.");
    }
    SQLSOLVER_Z3_TIMEOUT = Integer.parseInt(properties.getProperty(KEY_Z3_TIMEOUT, "10000"));
    SQLSOLVER_ENABLE_IC_SELECT = Boolean.parseBoolean(properties.getProperty(KEY_ENABLE_IC_SELECT, "true"));
    SQLSOLVER_FOLD_PREDICATES = Boolean.parseBoolean(properties.getProperty(KEY_FOLD_PREDICATES, "true"));
    LOG_LEVEL = Integer.parseInt(properties.getProperty(KEY_LOG_LEVEL, "0"));
    VERIFIER = properties.getProperty(KEY_VERIFIER, VERIFIER_SQLSOLVER);
    USE_HINT = properties.getProperty(KEY_USE_HINT, "");
    WORKERS = Integer.parseInt(properties.getProperty(KEY_WORKERS, "1"));
    VERIFIER_TIMEOUT = Integer.parseInt(properties.getProperty(KEY_VERIFIER_TIMEOUT, "-1"));
  }
}
