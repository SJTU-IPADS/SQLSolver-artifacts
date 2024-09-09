package sqlsolver.verifier.plan.symbolsql2sql.attrtree;

import static sqlsolver.common.utils.IterableSupport.*;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Tree<T> {
  public T extraAttr;   // more info about this node
  private final String tag;
  private final List<Tree<T>> children;

  public Tree(String tag, T extraAttr) {
    this.tag = tag;
    this.children = new ArrayList<>();
    this.extraAttr = extraAttr;
  }

  public String getTag() {
    return tag;
  }

  private Tree<T> find(Tree<T> tree, String symbol) {
    if (tree.tag.equals(symbol)) {
      return this;
    } else {
      for (Tree<T> child: children) {
        Tree<T> result = child.find(child, symbol);
        if (result != null) {
          return result;
        }
      }
      return null;
    }
  }
  public Tree<T> find(String symbol) {
    return find(this, symbol);
  }

  /**
   * Remove each edge (t1,t2) if
   * t1 can reach t2 via a path other than this edge.
   */
  public Tree<T> removeRedundantEdges() {
    removeRedundantEdges(new HashSet<>());
    return this;
  }

  /** Whether it is genuinely a tree. */
  public boolean isValid() {
    return isValidRecursive(new HashSet<>());
  }

  /**
   * Add newChild to children of this tree if it is not a child of this tree.
   */
  public void addChild(Tree<T> newChild) {
    for (Tree<T> child : children) {
      if (child == newChild) return;
    }
    children.add(newChild);
  }

  public List<Tree<T>> getChildren() {
    return children;
  }

  /**
   * Flatten this tree into a list of nodes in pre-order.
   */
  public List<Tree<T>> flattenPreOrder() {
    final List<Tree<T>> nodes = new ArrayList<>();
    flattenPreOrder(nodes);
    return nodes;
  }

  @Override
  public String toString() {
    final StringBuilder sb = new StringBuilder();
    print(sb, 0);
    return sb.toString();
  }

  private void print(StringBuilder sb, int level) {
    if (level > 0) {
      sb.append("   ".repeat(level - 1)).append("|- ");
    }
    if (children.isEmpty()) {
      sb.append(tag).append('\n');
    } else {
      sb.append(tag).append("[").append(extraAttr).append("]").append('\n');
      for (Tree<T> child : children) {
        child.print(sb, level + 1);
      }
    }
  }

  private void removeRedundantEdges(Set<Tree<T>> path) {
    // skip loops
    if (path.contains(this)) return;
    // update the path
    path.add(this);
    // recursion
    for (Tree<T> child : children) {
      child.removeRedundantEdges(path);
    }
    // remove an edge to a child if it is redundant
    boolean converges = false;
    while (!converges) {
      Tree<T> toRemove = null;
      for (Tree<T> child : children) {
        if (isRedundantEdge(this, child)) {
          toRemove = child;
          break;
        }
      }
      if (toRemove != null) children.remove(toRemove);
      else converges = true;
    }
    // restore the path
    path.remove(this);
  }

  private boolean isRedundantEdge(Tree<T> parent, Tree<T> child) {
    if (this == child) return true;
    // reach "child" without passing the edge (parent,child)
    return any(children, c ->
            (this != parent || c != child) && c.isRedundantEdge(parent, child));
  }

  private boolean isValidRecursive(Set<Tree<T>> visited) {
    if (visited.contains(this)) return false;
    visited.add(this);
    return all(children, child -> child.isValidRecursive(visited));
  }

  private void flattenPreOrder(List<Tree<T>> nodes) {
    nodes.add(this);
    for (Tree<T> child : children) {
      child.flattenPreOrder(nodes);
    }
  }
}
