package Entry.tpchTableSchema;

import com.google.common.collect.ImmutableList;
import org.apache.calcite.config.CalciteConnectionConfig;
import org.apache.calcite.rel.RelCollations;
import org.apache.calcite.rel.RelFieldCollation;
import org.apache.calcite.rel.type.RelDataType;
import org.apache.calcite.rel.type.RelDataTypeFactory;
import org.apache.calcite.schema.Schema;
import org.apache.calcite.schema.Statistic;
import org.apache.calcite.schema.Statistics;
import org.apache.calcite.schema.Table;
import org.apache.calcite.sql.SqlCall;
import org.apache.calcite.sql.SqlNode;
import org.apache.calcite.util.ImmutableBitSet;

public class ORDERS implements Table {
    public RelDataType getRowType(RelDataTypeFactory typeFactory) {
        RelDataTypeFactory.FieldInfoBuilder b = typeFactory.builder();
        b.add("O_ORDERKEY", typeFactory.createJavaType(Integer.class));
        b.add("O_CUSTKEY", typeFactory.createJavaType(Integer.class));
        b.add("O_ORDERSTATUS", typeFactory.createJavaType(String.class));
        b.add("O_TOTALPRICE", typeFactory.createJavaType(Double.class));
        b.add("O_ORDERDATE", typeFactory.createJavaType(String.class)); // date
        b.add("O_ORDERPRIORITY", typeFactory.createJavaType(String.class));
        b.add("O_CLERK", typeFactory.createJavaType(String.class));
        b.add("O_SHIPPRIORITY", typeFactory.createJavaType(Integer.class));
        b.add("O_COMMENT", typeFactory.createJavaType(String.class));
        return b.build();
    }
    @Override
    public boolean isRolledUp(String s) {
        return false;
    }
    @Override
    public boolean rolledUpColumnValidInsideAgg(String s, SqlCall sqlCall, SqlNode sqlNode, CalciteConnectionConfig calciteConnectionConfig) {
        return false;
    }
    public Statistic getStatistic() {
//        return Statistics.of(100, ImmutableList.<ImmutableBitSet>of());
        RelFieldCollation.Direction dir = RelFieldCollation.Direction.ASCENDING;
        RelFieldCollation collation = new RelFieldCollation(0, dir, RelFieldCollation.NullDirection.UNSPECIFIED);
        return Statistics.of(5, ImmutableList.of(ImmutableBitSet.of(0)),
                ImmutableList.of(RelCollations.of(collation)));
    }
    public Schema.TableType getJdbcTableType() {
        return Schema.TableType.STREAM;
    }

    public Table stream() {
        return null;
    }
}
