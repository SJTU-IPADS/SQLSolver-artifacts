#!/usr/bin/python3
import os
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-time', action='store_true', default=False, help='Show statistics of running time.')
    parser.add_argument('-tsv', action='store', default=None, help='Output running time into the specified file in .tsv format.')
    parser.add_argument('-tsv_neq', action='store_true', default=None, help='Output running time of NEQ cases in .tsv as well.')
    parser.add_argument('-tests', action='store', default='calcite', help='Specify the test set. Possible values: calcite (by default), spark, tpcc, tpch.')
    args = parser.parse_args()
    # print(args)
    tsv_str = '-tsv={}'.format(args.tsv) if args.tsv is not None else ''
    tests_str = ''
    if args.tests == 'calcite':
        tests_str = ''
    elif args.tests == 'spark':
        tests_str = '-D=db_rule_instances -i=spark_tests'
    elif args.tests == 'tpcc':
        tests_str = '-A=tpcc -D=prepared -i=rules.tpcc.spark.txt'
    elif args.tests == 'tpch':
        tests_str = '-A=tpch -D=prepared -i=rules.tpch.spark.txt'
    os.chdir("../other-verifiers/wetune")
    os.system("gradle :superopt:run --args='RunCalciteCasesWeTune -time={} {} -tsv_neq={} -T=VerifyRule -R=prepared/rules.txt {}'".format(args.time, tsv_str, args.tsv_neq, tests_str))
