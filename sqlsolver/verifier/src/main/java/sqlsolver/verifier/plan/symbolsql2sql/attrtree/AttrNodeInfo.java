package sqlsolver.verifier.plan.symbolsql2sql.attrtree;

import java.util.ArrayList;
import java.util.List;

/**
 * Info about a node in a forest of attribute list symbols.
 */
public class AttrNodeInfo {
  public enum NodeType {
    MULTI, SINGLE
  }

  NodeType type;       // useless
  boolean hasMoreColumns;
  final List<String> extraColumns;     // useless
  final List<Boolean> extraColumnsPresence; //useless

  public AttrNodeInfo(NodeType type) {
    this(type, new ArrayList<>());
  }

  public AttrNodeInfo(NodeType type, List<String> extraColumns) {
    this.type = type;
    this.hasMoreColumns = false;
    this.extraColumns = extraColumns;
    this.extraColumnsPresence = new ArrayList<>();
    for (int i = 0, bound = extraColumns.size(); i < bound; i++) {
      extraColumnsPresence.add(false);
    }
  }

  public NodeType getType() {
    return type;
  }

  /**
   * Whether this node has columns other than columns of its children.
   * It is useful during recursive enumeration of concrete SQL.
   */
  public boolean hasMoreColumns() {
    return hasMoreColumns;
  }

  public void setHasMoreColumns(boolean hasMoreColumns) {
    this.hasMoreColumns = hasMoreColumns;
  }

  public int getExtraColumnCount() {
    return extraColumns.size();
  }

  /**
   * Whether the index-th extra column of this node is present.
   * It is useful during recursive enumeration of concrete SQL.
   */
  public boolean isExtraColumnPresent(int index) {
    return extraColumnsPresence.get(index);
  }

  public void setExtraColumnPresent(int index, boolean isPresent) {
    extraColumnsPresence.set(index, isPresent);
  }

  public String getExtraColumn(int index) {
    return extraColumns.get(index);
  }

  public List<String> getExtraColumns() {
    return extraColumns;
  }

  @Override
  public String toString() {
    final StringBuilder sb = new StringBuilder();
    if (!extraColumns.isEmpty()) {
      sb.append("[+ ");
      for (int i = 0, bound = extraColumns.size(); i < bound; i++) {
        if (i > 0) sb.append(",");
        if (!extraColumnsPresence.get(i)) sb.append("(");
        sb.append(extraColumns.get(i));
        if (!extraColumnsPresence.get(i)) sb.append(")");
      }
      sb.append("] ");
    }
    sb.append(hasMoreColumns ? "> " : "= ").append(type).append(" ");
    return sb.toString();
  }
}
