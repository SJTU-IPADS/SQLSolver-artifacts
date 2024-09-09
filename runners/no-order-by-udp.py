#!/usr/bin/python3

import os
import argparse

CALCITE_TESTS_SCHEMA = 'schema_calcite'
SPARK_TESTS_SCHEMA = 'schema_calcite'
TPCC_TESTS_SCHEMA = 'schema_tpcc'
TPCH_TESTS_SCHEMA = 'schema_tpch'

parser = argparse.ArgumentParser()
parser.add_argument('-dir', action='store', default='tests/no_order_by', help='Specify the test directory.')
parser.add_argument('-tests', action='store', required=True, help='Specify the test set. Possible values: calcite, spark, tpcc, tpch.')
parser.add_argument('-udp', action='store', default='../other-verifiers/udp/Cosette/uexp/src/uexp/run', help='The UDP running directory.')
args = parser.parse_args()
if args.tests == 'calcite':
    schema = CALCITE_TESTS_SCHEMA
elif args.tests == 'spark':
    schema = SPARK_TESTS_SCHEMA
elif args.tests == 'tpcc':
    schema = TPCC_TESTS_SCHEMA
elif args.tests == 'tpch':
    schema = TPCH_TESTS_SCHEMA

os.chdir(args.udp)
os.system('python2 -u udp-calcite-no-order-by.py --dir=%s --tests=%s --schema=%s --regen' % (args.dir, args.tests, schema))
