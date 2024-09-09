package Entry.tpccTableSchema;

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

public class ORDER_LINE implements Table {
    public RelDataType getRowType(RelDataTypeFactory typeFactory) {
        RelDataTypeFactory.FieldInfoBuilder b = typeFactory.builder();
        b.add("OL_W_ID", typeFactory.createJavaType(Integer.class));
        b.add("OL_D_ID", typeFactory.createJavaType(Integer.class));
        b.add("OL_O_ID", typeFactory.createJavaType(Integer.class));
        b.add("OL_NUMBER", typeFactory.createJavaType(Integer.class));
        b.add("OL_I_ID", typeFactory.createJavaType(Integer.class));
        b.add("OL_DELIVERY_D", typeFactory.createJavaType(String.class)); // timestamp
        b.add("OL_AMOUNT", typeFactory.createJavaType(Double.class));
        b.add("OL_SUPPLY_W_ID", typeFactory.createJavaType(Integer.class));
        b.add("OL_QUANTITY", typeFactory.createJavaType(Integer.class));
        b.add("OL_DIST_INFO", typeFactory.createJavaType(String.class));
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
