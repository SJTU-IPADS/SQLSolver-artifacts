package sqlsolver.verifier.plan.symbolsql2sql.constraint;

import static sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint.Type.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint.Type;

/**
 * Load constraints from a string.
 */
public class ConstraintLoader {
  private static final Map<String, Type> typeMap;
  private static final Map<Type, Integer> typeArityMap;
  private static final Pattern constraintPattern;

  static {
    typeMap = new HashMap<>();
    typeMap.put("AttrsEq", ATTRS_EQ);
    typeMap.put("SchemaEq", SCHEMA_EQ);
    typeMap.put("TableEq", TABLE_EQ);
    typeMap.put("PredicateEq", PREDICATE_EQ);
    typeMap.put("AttrsSub", ATTRS_SUB);
    typeMap.put("Unique", UNIQUE);
    typeMap.put("NotNull", NOT_NULL);
    typeMap.put("Reference", REFERENCE);
    typeArityMap = new HashMap<>();
    typeArityMap.put(ATTRS_EQ, 2);
    typeArityMap.put(SCHEMA_EQ, 2);
    typeArityMap.put(TABLE_EQ, 2);
    typeArityMap.put(PREDICATE_EQ, 2);
    typeArityMap.put(ATTRS_SUB, 2);
    typeArityMap.put(UNIQUE, 2);
    typeArityMap.put(NOT_NULL, 2);
    typeArityMap.put(REFERENCE, 4);
    constraintPattern = Pattern.compile("[a-zA-Z]+\\([a-zA-Z0-9,]+\\)");
  }

  public List<Constraint> load(String constraintStr) {
    final List<Constraint> constraints = new ArrayList<>();
    final String[] parts = constraintStr.split(";");
    for (String part : parts) {
      // parse each constraint
      final Matcher matcher = constraintPattern.matcher(part);
      if (!matcher.matches()) {
        // ignore invalid constraints
        continue;
      }
      final int posLeftParen = part.indexOf("(");
      final int posRightParen = part.length() - 1;
      final String typeStr = part.substring(0, posLeftParen);
      final String argStr = part.substring(posLeftParen + 1, posRightParen);
      final Type type = typeMap.get(typeStr);
      final String[] args = argStr.split(",");
      if (args.length != typeArityMap.get(type)) {
        // ignore invalid constraints
        continue;
      }
      // add the constraint
      constraints.add(new Constraint(type, List.of(args)));
    }
    return constraints;
  }
}
