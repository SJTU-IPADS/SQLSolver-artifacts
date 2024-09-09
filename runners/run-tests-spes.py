#!/usr/bin/python3
import os
import argparse

command = 'mvn exec:java -Dexec.mainClass="Entry.simpleTest"'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # parser.add_argument('--test2', type=int, required=True)
    parser.add_argument('-time', action='store_true', default=False, help='Show statistics of running time.')
    parser.add_argument('-tsv', action='store', default=None, help='Output running time into the specified file in .tsv format.')
    parser.add_argument('-tests', action='store', required=True, help='Specify the test set. Possible values: calcite, spark, tpcc, tpch.')
    args = parser.parse_args()
    # print(args)
    tsv_str = '-tsv={}'.format(args.tsv) if args.tsv is not None else ''
    tests_file = ''
    case_ = ''
    if args.tests == 'calcite':
        tests_file = 'tests/calcite/calcite_tests'
        case_ = 'calcite'
    elif args.tests == 'spark':
        tests_file = 'tests/db_rule_instances/spark_tests'
        case_ = 'calcite'
    elif args.tests == 'tpcc':
        tests_file = 'tests/prepared/rules.tpcc.spark.txt'
        case_ = 'tpcc'
    elif args.tests == 'tpch':
        tests_file = 'tests/prepared/rules.tpch.spark.txt'
        case_ = 'tpch'
    os.chdir('../other-verifiers/spes')
    os.environ['LD_LIBRARY_PATH'] = os.getcwd()
    arg_str = ' -Dexec.args="' + " '{}'".format(tests_file) + " -case={} ".format(case_) + " -time={} {}".format(args.time, tsv_str) + '"'
    os.system(command + arg_str)
