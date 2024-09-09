#!/usr/bin/python3
import os
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-tests', action='store', required=True, help='Specify the test set. Possible values: calcite, spark, tpcc, tpch.')
    args = parser.parse_args()
    tests = args.tests
    app = 'calcite_test'
    if tests == 'tpcc':
        app = 'tpcc'
    elif tests == 'tpch':
        app = 'tpch'
    # print(args)
    os.chdir('../other-verifiers/wetune')
    os.system("gradle :superopt:run --args='RunCalciteNoOrderByWeTune -T=VerifyRule -R=prepared/rules.txt -D=no_order_by -A=%s -i=tests_%s -l=tags_%s'" % (app, tests, tests))
