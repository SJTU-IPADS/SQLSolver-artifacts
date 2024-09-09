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

public class LINEITEM implements Table {
    public RelDataType getRowType(RelDataTypeFactory typeFactory) {
        RelDataTypeFactory.FieldInfoBuilder b = typeFactory.builder();
        b.add("L_ORDERKEY", typeFactory.createJavaType(Integer.class));
        b.add("L_PARTKEY", typeFactory.createJavaType(Integer.class));
        b.add("L_SUPPKEY", typeFactory.createJavaType(Integer.class));
        b.add("L_LINENUMBER", typeFactory.createJavaType(Integer.class));
        b.add("L_QUANTITY", typeFactory.createJavaType(Double.class));
        b.add("L_EXTENDEDPRICE", typeFactory.createJavaType(Double.class));
        b.add("L_DISCOUNT", typeFactory.createJavaType(Double.class));
        b.add("L_TAX", typeFactory.createJavaType(Double.class));
        b.add("L_RETURNFLAG", typeFactory.createJavaType(String.class));
        b.add("L_LINESTATUS", typeFactory.createJavaType(String.class));
        b.add("L_SHIPDATE", typeFactory.createJavaType(String.class)); //date
        b.add("L_COMMITDATE", typeFactory.createJavaType(String.class)); //date
        b.add("L_RECEIPTDATE", typeFactory.createJavaType(String.class)); //date
        b.add("L_SHIPINSTRUCT", typeFactory.createJavaType(String.class));
        b.add("L_SHIPMODE", typeFactory.createJavaType(String.class));
        b.add("L_COMMENT", typeFactory.createJavaType(String.class));
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
