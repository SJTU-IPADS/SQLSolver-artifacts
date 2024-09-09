#!/usr/bin/python3
import os
import argparse
import time
from subprocess import Popen, PIPE, STDOUT

# constants

ROUNDS = 5

SPARK_TESTS_DIR = 'tests/db_rule_instances'
TPCC_TESTS_DIR = 'tests/prepared'
TPCH_TESTS_DIR = 'tests/prepared'

SPARK_TESTS_FILE = 'spark_tests'
TPCC_TESTS_FILE = 'rules.tpcc.spark.txt'
TPCH_TESTS_FILE = 'rules.tpch.spark.txt'

SPARK_TESTS_SCHEMA = 'schema_calcite'
TPCC_TESTS_SCHEMA = 'schema_tpcc'
TPCH_TESTS_SCHEMA = 'schema_tpch'

# global vars

# functions

def millis():
    return round(time.time() * 1000)

def lean_check_sorry(output):
    return "warning: declaration 'rule' uses sorry" in output

def is_success(ret, output):
    return ret == 0 and not lean_check_sorry(output)

def test_calcite(btime, tsv):
    time_str = "-time" if btime else ""
    tsv_str = ("-tsv=%s" % tsv) if tsv else ""
    os.system("python2 -u auto-udp.py " + time_str + " " + tsv_str)

def test_custom(dir, file, alias, schema, btime, tsv):
    time_str = "--time" if btime else ""
    tsv_str = ("--tsv=%s" % tsv) if tsv else ""
    os.system("python2 -u auto-udp-run.py --dir=" + dir + " --tests=" + file + " --alias=" + alias + " --schema=" + schema + " --regen " + time_str + " " + tsv_str)

def test_spark(btime, tsv):
    test_custom(SPARK_TESTS_DIR, SPARK_TESTS_FILE, 'spark', SPARK_TESTS_SCHEMA, btime, tsv)

def test_tpcc(btime, tsv):
    test_custom(TPCC_TESTS_DIR, TPCC_TESTS_FILE, 'tpcc', TPCC_TESTS_SCHEMA, btime, tsv)

def test_tpch(btime, tsv):
    test_custom(TPCH_TESTS_DIR, TPCH_TESTS_FILE, 'tpch', TPCH_TESTS_SCHEMA, btime, tsv)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-time', action='store_true', default=False)
    parser.add_argument('-tests', action='store', required=True, help='Specify the test set. Possible values: calcite, spark, tpcc, tpch.')
    parser.add_argument('-udp', action='store', default='../other-verifiers/udp/Cosette/uexp/src/uexp/run', help='The UDP running directory.')
    parser.add_argument('-dir', action='store', default=SPARK_TESTS_DIR, help='Specify the test directory.')
    parser.add_argument('-file', action='store', default='spark_tests', help='Specify the test file name.')
    parser.add_argument('-alias', action='store', default='spark', help='Specify the test set alias.')
    parser.add_argument('-schema', action='store', default='schema_calcite', help='Specify the table schemas.')
    parser.add_argument('-tsv', action='store', default=None, help='Output running time into the specified file in .tsv format.')
    args = parser.parse_args()
    btime = args.time
    dir = args.dir
    file = args.file
    alias = args.alias
    schema = args.schema
    tsv = args.tsv
    os.chdir(args.udp)
    if args.tests == 'calcite':
        test_calcite(btime, tsv)
    elif args.tests == 'spark':
        test_spark(btime, tsv)
    elif args.tests == 'tpcc':
        test_tpcc(btime, tsv)
    elif args.tests == 'tpch':
        test_tpch(btime, tsv)
    else:
        test_custom(dir, file, alias, schema, btime, tsv)
