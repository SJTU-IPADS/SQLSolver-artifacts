package sqlsolver.verifier.plan.rule2symbolsql;

import java.util.*;
import java.util.regex.Pattern;

import sqlsolver.superopt.constraint.Constraint;
import sqlsolver.superopt.fragment.Symbol;
import sqlsolver.superopt.fragment.SymbolNaming;
import sqlsolver.superopt.fragment.Symbols;

public class EqConstraintsUnionFind {
  private UnionFind tableEqClasses;
  private UnionFind attrsEqClasses;
  private UnionFind predEqClasses;
  private UnionFind funcEqClasses;
  private UnionFind schemaEqClasses;
  private final Symbols symbols;
  private final SymbolNaming naming;
  private final List<Constraint> constraints;

  public EqConstraintsUnionFind(Symbols symbols, SymbolNaming naming, List<Constraint> constraints) {
    this.symbols = symbols;
    this.naming = naming;
    this.constraints = constraints;

    tableEqClasses = constructUnionFind(Symbol.Kind.TABLE);
    attrsEqClasses = constructUnionFind(Symbol.Kind.ATTRS);
    predEqClasses = constructUnionFind(Symbol.Kind.PRED);
  }

  private Constraint.Kind symbolKindToConstKind(Symbol.Kind kind) {
    switch (kind) {
      case PRED: return Constraint.Kind.PredicateEq;
      case ATTRS: return Constraint.Kind.AttrsEq;
      case TABLE: return Constraint.Kind.TableEq;
      default : throw new RuntimeException();
    }
  }

  private UnionFind constructUnionFind(Symbol.Kind kind) {
    ArrayList<String> names = new ArrayList<>();
    for (Symbol symbol : symbols.symbolsOf(kind)) {
      names.add(naming.nameOf(symbol));
    }
    names.sort(Comparator.naturalOrder());
    UnionFind unionFind = new UnionFind(names);
    for (Constraint constraint : constraints) {
      if (constraint.kind()== symbolKindToConstKind(kind)) {
        String name0 = naming.nameOf(constraint.symbols()[0]);
        int id0 = Integer.parseInt(name0.substring(1));
        String name1 = naming.nameOf(constraint.symbols()[1]);
        int id1 = Integer.parseInt(name1.substring(1));
        String smallName = id0 > id1 ? name1 : name0;
        String bigName = id0 > id1 ? name0 : name1;
        unionFind.union(smallName, bigName);
      }
    }
    return unionFind;
  }

  private UnionFind getUnionFind(Symbol.Kind kind) {
    return switch (kind) {
      case TABLE -> tableEqClasses;
      case ATTRS -> attrsEqClasses;
      case PRED -> predEqClasses;
      default -> schemaEqClasses;
    };
  }

  public String realSymbolName(String name, Symbol.Kind kind) {
    UnionFind unionFind = getUnionFind(kind);
    assert unionFind != null;
    return unionFind.findRootName(name);
  }


  public String unifySymbolNames(String str, Symbol.Kind kind) {
    UnionFind unionFind = getUnionFind(kind);
    assert unionFind != null;
    for (Symbol symbol : symbols.symbolsOf(kind)) {
      String name = naming.nameOf(symbol);
      String rootName = unionFind.findRootName(name);
      if (!name.equals(rootName)) {
        String regex = "\\b" + Pattern.quote(name) + "\\b";
        str = str.replaceAll(regex, rootName);
        // str = str.replace(name, rootName);
      }
    }
    return str;
  }
}


class UnionFind {

  private final int[] forest;
  private final int length;
  private final String[] names;

  public UnionFind(ArrayList<String> names) {
    int cardinality = names.size();
    this.forest = new int[cardinality];
    this.length = cardinality;
    for (int i = 0; i < this.length; ++ i)
      this.forest[i] = i;
    this.names = new String[names.size()];
    for (int i = 0; i < this.length; ++ i) {
      this.names[i] = names.get(i);
    }
  }

  public void union(String name1, String name2) {
    int index1 = indexOfName(name1);
    assert index1 != -1;
    int index2 = indexOfName(name2);
    assert index2 != -1;
    int root1 = find(index1);
    int root2 = find(index2);
    forest[root2] = root1;
  }

  private int find(int index) {
    int root = index;
    while (forest[root] != root) {
      root = forest[root];
    }
    return root;
  }

  public String findRootName(String name) {
    int index = indexOfName(name);
    assert (index != -1);
    return names[find(index)];
  }

  private int indexOfName(String name) {
    for (int i = 0; i < length; ++ i) {
      if (names[i].equals(name))
        return i;
    }
    return -1;
  }

  public int numOfTrees() {
    int num = 0;
    for (int i = 0; i < length; ++ i) {
      if (forest[i] == i)
        num = num + 1;
    }
    return num;
  }

  public ArrayList<String> rootNames() {
    ArrayList<String> rootNames = new ArrayList<>();
    for (int i = 0; i < length; ++ i) {
      if (forest[i] == i)
        rootNames.add(names[i]);
    }
    return rootNames;
  }
}

