module sqlsolver.verifier {
  exports sqlsolver.verifier.plan;
  exports sqlsolver.verifier.runner;

  requires sqlsolver.api;
  requires sqlsolver.common;
  requires sqlsolver.sql;
  requires sqlsolver.stmt;
  requires sqlsolver.superopt;
  requires calcite.core;
  requires com.google.common;
  requires org.checkerframework.checker.qual;
  requires java.xml;
  requires trove4j;
}
