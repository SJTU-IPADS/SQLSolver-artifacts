package sqlsolver.common.utils;

import java.io.OutputStream;
import java.io.PrintStream;
import java.util.function.Supplier;

public class Muter {
  /**
   * Execute the specified method with the standard output and error muted.
   * Return the return value of the method.
   */
  public static <T> T mute(Supplier<T> method) {
    final PrintStream stdOut = System.out;
    final PrintStream stdErr = System.err;
    final PrintStream silentOut = new PrintStream(new OutputStream() {
      @Override
      public void write(int b) {}
    });
    final T result;
    try {
      // mute standard output and error
      System.setOut(silentOut);
      System.setErr(silentOut);
      // execute the method
      result = method.get();
    } finally {
      // restore standard output and error
      System.setOut(stdOut);
      System.setErr(stdErr);
    }
    return result;
  }
}
