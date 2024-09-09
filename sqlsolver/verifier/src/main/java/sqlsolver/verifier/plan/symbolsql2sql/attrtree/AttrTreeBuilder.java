package sqlsolver.verifier.plan.symbolsql2sql.attrtree;

import java.util.*;

import org.apache.calcite.sql.*;
import sqlsolver.verifier.plan.symbolsql2sql.verification.SymbolicVerifier;
import sqlsolver.verifier.plan.symbolsql2sql.constraint.Constraint;

import static sqlsolver.verifier.plan.symbolsql2sql.attrtree.AttrNodeInfo.NodeType.SINGLE;
import static sqlsolver.verifier.plan.symbolsql2sql.attrtree.AttrNodeInfo.NodeType.MULTI;
import static sqlsolver.verifier.plan.symbolsql2sql.util.SqlNodeSupport.*;

/**
 * Build a forest of containment between attribute lists.
 * A parent attribute list contains all attributes of its children.
 * The root of each tree must be present, and it does not stand for an attribute list.
 */
public class AttrTreeBuilder {
  /** The name and type of the source attribute list / table. */
  private record Source(String tag, AttrNodeInfo.NodeType type) {}

  /**
   * <p>
   * Build a forest of containment between attribute lists.
   * A parent attribute list contains all attributes of its children.
   * The root of each tree must be present, and it does not stand for an attribute list.
   * </p>
   * Note that the given ASTs of symbolic queries and constraints should follow the same requirements
   * as {@link SymbolicVerifier#verify(String, String, List) SymbolicVerifier}.
   */
  public List<Tree<AttrNodeInfo>> build(SqlNode ast0, SqlNode ast1, List<Constraint> constraints) {
    // build a forest from constraints
    final Map<String, Tree<AttrNodeInfo>> trees = new HashMap<>();
    final Set<String> rootTags = new HashSet<>();
    for (Constraint constraint : constraints) {
      if (constraint.type() != Constraint.Type.ATTRS_SUB) continue;
      final String childTag = constraint.args().get(0);
      final String originalParentTag = constraint.args().get(1);
      // get the attr list and extra columns from the actual schema of the parent table/subquery
      final List<String> parentExtraColumns = new ArrayList<>();
      Source parentSrc;
      try {
        parentSrc = findSourceAttrs(ast0, originalParentTag, parentExtraColumns);
      } catch (IllegalArgumentException e) {
        parentSrc = findSourceAttrs(ast1, originalParentTag, parentExtraColumns);
        // if source attr list not found in both queries, an exception is thrown by findSourceAttrs
      }
      if (parentSrc == null) {
        // TODO: support multiple extra columns as a root node
        assert false;
        //assert parentExtraColumns.size() == 1;
        //parentSrc = new Source(parentExtraColumns.get(0), SINGLE);
      }
      // ignore self-sub constraints (AttrsSub(aN,aN))
      if (childTag.equals(parentSrc.tag)) continue;
      // create the parent node if necessary
      Tree<AttrNodeInfo> parentNode = trees.get(parentSrc.tag);
      if (parentNode == null) {
        // a new parent node is a root node
        rootTags.add(parentSrc.tag);
        parentNode = new Tree<>(parentSrc.tag, new AttrNodeInfo(parentSrc.type));
        trees.put(parentSrc.tag, parentNode);
      }
      // create the child node if necessary
      final Tree<AttrNodeInfo> childNode = trees.computeIfAbsent(childTag,
              tag -> new Tree<>(tag, new AttrNodeInfo(MULTI)));
      for (String extraColumn : parentExtraColumns) {
        childNode.extraAttr.extraColumns.add(extraColumn);
        childNode.extraAttr.extraColumnsPresence.add(false);
      }
      // remove the child node from the root set if present
      rootTags.remove(childTag);
      // connect the parent and child
      parentNode.addChild(childNode);
    }
    // check validity and aggregate trees
    final List<Tree<AttrNodeInfo>> forest = new ArrayList<>();
    for (String rootTag : rootTags) {
      final Tree<AttrNodeInfo> tree = trees.get(rootTag).removeRedundantEdges();
      if (!tree.isValid()) reportError();
      forest.add(tree);
    }
    // propagate the "SINGLE" node type
    for (Tree<AttrNodeInfo> tree : forest) {
      if (tree.extraAttr.type == SINGLE) {
        setNodeTypeRecursive(tree, SINGLE);
      }
    }
    // append tables absent in constraints to the forest
    final Set<String> tableNames = collectTableNames(ast0);
    tableNames.addAll(collectTableNames(ast1));
    for (String table : tableNames) {
      if (!rootTags.contains(table)) {
        forest.add(new Tree<>(table, new AttrNodeInfo(MULTI)));
      }
    }
    return forest;
  }

  private SqlNode locateRelation(SqlNode ast, SqlNode parent, String relation) {
    if (ast == null) {
      return null;
    }

    // 如果是一个简单的标识符（如表名或别名）
    if (ast instanceof SqlIdentifier) {
      SqlIdentifier identifier = (SqlIdentifier) ast;
      if (relation.equalsIgnoreCase(identifier.toString())) {
        return parent;
      } else return null;
    }

    // 如果是一个SELECT语句
    if (ast instanceof SqlSelect) {
      SqlSelect select = (SqlSelect) ast;

      // 递归查找 FROM 部分
      SqlNode from = select.getFrom();
      SqlNode result = locateRelation(from, select, relation);
      if (result != null) {
        return result;
      }

      // EXISTS或IN可能出现在where部分
      SqlNode where = select.getWhere();
      if (where instanceof SqlBasicCall) {
        SqlBasicCall call = (SqlBasicCall) where;
        String name = call.getOperator().getName();
        if (name.equals("EXISTS") || name.equals("IN")) {
          result = locateRelation(where, ast, relation);
          if (result != null) {
            return result;
          }
        }
      }

      // (select a0 as r0, sum(a1) as r1 from ... group by a0 having e0(a2)) as r2
      SqlNodeList selectList = select.getSelectList();
      for (SqlNode sqlNode: selectList) {
        if (sqlNode instanceof SqlBasicCall call) {
          if (call.getOperator().getName() == "AS") {
            result = locateRelation(call.operand(1), call, relation);
          }
          if (result != null) {
            return result;
          }
        }
      }
    }

    // 如果是一个JOIN语句
    if (ast instanceof SqlJoin) {
      SqlJoin join = (SqlJoin) ast;

      // 递归查找左侧表
      SqlNode left = join.getLeft();
      SqlNode result = locateRelation(left, join, relation);
      if (result != null) {
        return result;
      }

      // 递归查找右侧表
      SqlNode right = join.getRight();
      result = locateRelation(right, join, relation);
      if (result != null) {
        return result;
      }
    }

    if (ast instanceof SqlBasicCall) {
      SqlBasicCall call = (SqlBasicCall) ast;
      String name = call.getOperator().getName();
      switch (name) {
        case "AS", "UNION", "UNION ALL": {
          SqlNode result = locateRelation(call.operand(0), call, relation);
          if (result != null) {
            return result;
          }
          result = locateRelation(call.operand(1), call, relation);
          if (result != null) {
            return result;
          }
          break;
        }
        case "EXISTS": {
          SqlNode result = locateRelation(call.operand(0), call, relation);
          if (result != null) {
            return result;
          }
          break;
        }
        case "IN": {
          SqlNode result = locateRelation(call.operand(1), call, relation);
          if (result != null) {
            return result;
          }
          break;
        }
        default: {
          // other kinds of expressions, I suppose there's no relation here.
        }
      }
    }

    // 如果在当前节点没有找到，返回 null
    return null;
  }

  private String goDownToResult(SqlNode ast, String relation) {
    if (ast instanceof SqlIdentifier identifier) {
      return removeQualification(identifier).toString();
    }

    if (ast instanceof SqlSelect select) {
      SqlNodeList selectList = select.getSelectList();
      // select *
      if (selectList.size() == 1) {
        SqlNode firstNode = selectList.get(0);
        if (firstNode instanceof SqlIdentifier identifier) {
          if (identifier.isStar()) {
            SqlNode from = select.getFrom();
            return goDownToResult(from, relation);
          }
        }
      }

      SqlNode firstNode = selectList.get(0);
      if (firstNode instanceof SqlIdentifier identifier) {
        // select a
        return removeQualification(identifier).toString();
      } else if (firstNode instanceof SqlBasicCall call) {
        // select e(a)
        return call.getOperator().getName();
      }

      return null;
    }

    if (ast instanceof SqlBasicCall call) {
      String name = call.getOperator().getName();
      switch (name) {
        case "AS", "UNION", "UNION ALL": {
          return goDownToResult(call.operand(0), relation);
        }
        default: {
          return name;
        }
      }
    }
    return "NULL";
  }

  private String locateResult(SqlNode sqlNode, String relation) {
    if (sqlNode instanceof SqlSelect select) {
      SqlNode from = select.getFrom();
      return goDownToResult(from, relation);
    }

    if (sqlNode instanceof SqlBasicCall call) {
      String name = call.getOperator().getName();
      if (name.equals("AS")) {
        return goDownToResult(call.operand(0), relation);
      }
    }
    return "NULL";
  }

  /**
   * @brief find the real symbol to put in the attr tree
   * @return if relation doesn't exist, return null
   * if relation exist, return the parent attribute or real table
   * */
  private String findSource(SqlNode ast, String relation) {
    SqlNode sqlNode = locateRelation(ast, null, relation);
    if (sqlNode == null) {
      return "NULL";
    } else {
      return locateResult(sqlNode, relation);
    }
  }

  public List<Tree<Boolean>> buildForest(SqlNode ast0, List<Constraint> constraints) {
    final Map<String, Tree<Boolean>> trees = new HashMap<>();
    for (Constraint constraint: constraints) {
      final String attribute = constraint.args().get(0);
      final String relation = constraint.args().get(1);
      final String source = relation.charAt(0) == 'A' ? relation : findSource(ast0, relation);
      if (source.equals("NULL")) {
        // didn't find the source
      } else if (source.charAt(0) == 'A') {
        boolean flag = false;
        for (Map.Entry<String, Tree<Boolean>> entry: trees.entrySet()) {
          Tree<Boolean> existed = entry.getValue().find(source);
          if (existed != null) {
            flag = true;
            existed.addChild(new Tree<>(attribute, false));
            break;
          }
        }
        if (!flag) {
          trees.put(source, new Tree<>(source, false));
          trees.get(source).addChild(new Tree<>(attribute, false));
        }
      } else {
        // in case the root is a relation or expression or agg operator
        if (trees.containsKey(source)) {
          trees.get(source).addChild(new Tree<>(attribute, false));
        } else {
          trees.put(source, new Tree<>(source, false));
          trees.get(source).addChild(new Tree<>(attribute, false));
        }
      }
    }

    List<Tree<Boolean>> result = new ArrayList<>();
    for (Map.Entry<String, Tree<Boolean>> entry: trees.entrySet()) {
      result.add(entry.getValue());
    }
    return result;
  }

  private void setNodeTypeRecursive(Tree<AttrNodeInfo> node, AttrNodeInfo.NodeType type) {
    node.extraAttr.type = type;
    for (Tree<AttrNodeInfo> child : node.getChildren()) {
      setNodeTypeRecursive(child, type);
    }
  }

  /**
   * Find in the given AST the schema specified by the given alias
   * (i.e. which attribute list symbol corresponds to this alias).
   * @param extraColumns extra columns (e.g. agg(aX)) besides the source attribute list will be appended to this list
   * @return the corresponding attribute list symbol, or
   *         <code>null</code> if the builder cannot find that symbol in the given AST
   */
  private Source findSourceAttrs(SqlNode ast, String alias, List<String> extraColumns) {
    final List<Source> result = new ArrayList<>(1);
    matchOnce(ast, node -> {
      if (node instanceof SqlBasicCall call
              && call.getOperator() instanceof SqlAsOperator
              && call.operand(1) instanceof SqlIdentifier id
              && id.names.size() == 1
              && id.getSimple().equals(alias)) {
        // ... AS "alias"
        result.add(findSourceAttrsRecursive(call.operand(0), alias, extraColumns));
        return true;
      } else if (node instanceof SqlIdentifier table
              && table.names.get(table.names.size() - 1).equals(alias)) {
        // "(XX.)alias" or "(XX.)alias" AS ...
        // "alias" is an input table name or attribute list name
        result.add(new Source(alias, MULTI));
        return true;
      }
      return false;
    });
    // alias should be unique
    assert result.size() <= 1;
    if (result.isEmpty())
      throw new IllegalArgumentException("source attr list not found");
    return result.get(0);
  }

  /**
   * Find the top attribute list symbol showing the schema of "ast".
   * Columns other than that symbol are appended to "extraColumns".
   */
  private Source findSourceAttrsRecursive(SqlNode ast, String srcAlias, List<String> extraColumns) {
    ast = removeAlias(ast);
    if (ast instanceof SqlSelect select) {
      final SqlNodeList selectList = select.getSelectList();
      if (selectList.size() == 1 && isStar(selectList.get(0))) {
        // "SELECT *" does not claim the schema; dig deeper
        return findSourceAttrsRecursive(select.getFrom(), srcAlias, extraColumns);
      }
      // has reached the source schema
      // collect the attr list symbol and extra columns
      SqlIdentifier attrListSymbol = null;
      for (SqlNode item : selectList) {
        final SqlIdentifier alias = getAlias(item);
        item = removeAlias(item);
        if (item instanceof SqlIdentifier id) {
          // attr list symbol
          // multiple attr list symbols in the schema are not allowed
          if (attrListSymbol == null) attrListSymbol = id;
          else throw new UnsupportedOperationException("The schema of " + ast + " should contain exactly one attribute list");
        } else if (alias != null && isSingleColumn(item)) {
          // must be exactly one column
          extraColumns.add(alias.getSimple());
        } else {
          // not supported
          throw new UnsupportedOperationException("The schema of " + ast + " contains unsupported item kind " + item.getKind());
        }
      }
      // no attr list symbol is found
      if (attrListSymbol == null) return null;
      // exactly one attr list symbol is found
      final String tag = removeQualification(attrListSymbol).toString();
      return new Source(tag, MULTI);
    } else if (ast instanceof SqlIdentifier srcAttr) {
      return new Source(srcAttr.getSimple(), MULTI);
    } else if (isSingleColumn(ast)) {
      // function call always leads to a single column
      return new Source(srcAlias, SINGLE);
    }
    throw new UnsupportedOperationException(ast.getKind() + " is not supported");
  }

  /**
   * Collect all table names (not aliases) in the query AST.
   */
  private Set<String> collectTableNames(SqlNode ast) {
    // collect SELECT (sub-)queries in ast
    final List<SqlNode> selectNodes = match(ast,
            node -> node instanceof SqlSelect);
    // collect table names from "FROM" clauses
    final Set<String> tableNames = new HashSet<>();
    for (SqlNode node : selectNodes) {
      final SqlSelect select = (SqlSelect) node;
      final SqlNode from = select.getFrom();
      if (from != null && removeAlias(from) instanceof SqlIdentifier tableId) {
        tableNames.add(tableId.getSimple());
      }
    }
    return tableNames;
  }

  private void reportError() {
    throw new IllegalArgumentException("invalid containment relation between attribute lists");
  }
}
