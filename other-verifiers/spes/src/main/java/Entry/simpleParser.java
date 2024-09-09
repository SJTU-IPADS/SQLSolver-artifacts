package Entry;

import org.apache.calcite.adapter.java.JavaTypeFactory;
import org.apache.calcite.jdbc.JavaTypeFactoryImpl;
import org.apache.calcite.rel.RelNode;
import org.apache.calcite.rel.type.RelDataTypeSystem;
import org.apache.calcite.schema.SchemaPlus;
import org.apache.calcite.sql.SqlNode;
import org.apache.calcite.sql.parser.SqlParseException;
import org.apache.calcite.sql2rel.SqlToRelConverter;
import org.apache.calcite.tools.*;

public class simpleParser {
        public static final JavaTypeFactory typeFactory = new JavaTypeFactoryImpl(RelDataTypeSystem.DEFAULT);
        public static final SchemaPlus defaultSchema = Frameworks.createRootSchema(true);

        private FrameworkConfig config = Frameworks.newConfigBuilder().defaultSchema(defaultSchema).build();
        private Planner planner = Frameworks.getPlanner(config);

        public simpleParser(){
            addTableSchema("calcite");
        }

        public simpleParser(String case_){
            addTableSchema(case_);
        }

        public void addTableSchema(String case_){
            SqlToRelConverter.configBuilder().build();
            switch (case_) {
                case "calcite": {
                    // calcite
                    defaultSchema.add("T", new Entry.tableSchema.T());
                    defaultSchema.add("ANON", new Entry.tableSchema.ANON());
                    defaultSchema.add("EMP", new Entry.tableSchema.EMP());
                    defaultSchema.add("DEPT",new Entry.tableSchema.DEPT());
                    defaultSchema.add("BONUS",new Entry.tableSchema.BONUS());
                    defaultSchema.add("ACCOUNT",new Entry.tableSchema.ACCOUNT());
                    break;
                }
                case "tpch": {
                    // tpch
                    defaultSchema.add("CUSTOMER", new Entry.tpchTableSchema.CUSTOMER());
                    defaultSchema.add("LINEITEM", new Entry.tpchTableSchema.LINEITEM());
                    defaultSchema.add("NATION", new Entry.tpchTableSchema.NATION());
                    defaultSchema.add("ORDERS", new Entry.tpchTableSchema.ORDERS());
                    defaultSchema.add("PART", new Entry.tpchTableSchema.PART());
                    defaultSchema.add("PARTSUPP", new Entry.tpchTableSchema.PARTSUPP());
                    defaultSchema.add("REGION", new Entry.tpchTableSchema.REGION());
                    defaultSchema.add("SUPPLIER", new Entry.tpchTableSchema.SUPPLIER());
                    break;
                }
                case "tpcc": {
                    // tpcc
                    defaultSchema.add("CUSTOMER", new Entry.tpccTableSchema.CUSTOMER());
                    defaultSchema.add("DISTRICT", new Entry.tpccTableSchema.DISTRICT());
                    defaultSchema.add("HISTORY", new Entry.tpccTableSchema.HISTORY());
                    defaultSchema.add("ITEM", new Entry.tpccTableSchema.ITEM());
                    defaultSchema.add("NEW_ORDER", new Entry.tpccTableSchema.NEW_ORDER());
                    defaultSchema.add("OORDER", new Entry.tpccTableSchema.OORDER());
                    defaultSchema.add("ORDER_LINE", new Entry.tpccTableSchema.ORDER_LINE());
                    defaultSchema.add("STOCK", new Entry.tpccTableSchema.STOCK());
                    defaultSchema.add("WAREHOUSE", new Entry.tpccTableSchema.WAREHOUSE());
                    break;
                }
                default: {}
            }
        }

        public RelNode getRelNode(String sql) throws SqlParseException, ValidationException, RelConversionException{
            SqlNode parse = planner.parse(sql);
            //System.out.println(parse.toString());
            SqlToRelConverter.configBuilder().build();
            SqlNode validate = planner.validate(parse);
            RelNode tree = planner.rel(validate).rel;
            //String plan = RelOptUtil.toString(tree,SqlExplainLevel.EXPPLAN_ATTRIBUTES); //explain(tree, SqlExplainLevel.ALL_ATTRIBUTES);
            //System.out.println(plan);
            return tree;
        }
    }
