package sqlsolver.verifier;

import sqlsolver.verifier.runner.Runner;

public class Entry {
  public static void main(String[] args) throws Exception {
    if (!args[0].startsWith("runner.")) args[0] = "runner." + args[0];
    final String clsName = Entry.class.getPackageName() + "." + args[0];
    final Class<?> cls = Class.forName(clsName);

    if (!Runner.class.isAssignableFrom(cls)) {
      System.err.println("not a runner");
      return;
    }

    final Runner runner = (Runner) cls.getConstructor().newInstance();
    runner.prepare(args);
    runner.run();
    runner.stop();
  }
}
