package sqlsolver.verifier.plan.symbolsql2sql.constraint;

import sqlsolver.common.utils.ListSupport;

import java.util.List;

public record Constraint(Type type, List<String> args) {
  public enum Type {
    ATTRS_EQ("AttrsEq", false),
    SCHEMA_EQ("SchemaEq", false),
    TABLE_EQ("TableEq", false),
    PREDICATE_EQ("PredicateEq", false),
    ATTRS_SUB("AttrsSub", false),
    UNIQUE("Unique", true),
    NOT_NULL("NotNull", true),
    REFERENCE("Reference", true);

    private final String name;
    private final boolean isIC;

    Type(String name, boolean isIC) {
      this.name = name;
      this.isIC = isIC;
    }

    @Override
    public String toString() {
      return name;
    }
  }

  /**
   * Return a new copy of constraint where symbols are capitalized.
   */
  public Constraint capitalize() {
    return new Constraint(type, ListSupport.map(args, String::toUpperCase));
  }

  public boolean isIntegrityConstraint() {
    return type.isIC;
  }

  @Override
  public String toString() {
    return type + "(" + String.join(",", args) + ")";
  }
}
