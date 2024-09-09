#!/usr/bin/python3
import os
import argparse
import re
from subprocess import Popen, PIPE, STDOUT

command_prefix = 'mvn exec:java -Dexec.mainClass="Entry.simpleTest" '

def load_tags(tests):
    global tags
    with open('tests/no_order_by/tags_%s' % tests, 'r') as ofile:
        tags = list(map(lambda s: s.strip(), ofile.readlines()))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-tests', action='store', required=True, help='Specify the test set. Possible values: calcite, spark, tpcc, tpch.')
    args = parser.parse_args()
    # print(args)
    schema = 'calcite'
    if args.tests == 'tpcc':
        schema = 'tpcc'
    elif args.tests == 'tpch':
        schema = 'tpch'
    # run SPES
    os.chdir('../other-verifiers/spes')
    load_tags(args.tests)
    arg_str = '-Dexec.args="' + "'tests/no_order_by/tests_%s' -case=%s" % (args.tests, schema) + '"'
    real_cmd = command_prefix + arg_str
    proc = Popen(real_cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, env=dict(os.environ, LD_LIBRARY_PATH=os.getcwd()))
    # beautify output
    output = proc.communicate()[0].decode()
    output_lines = output.split('\n')
    for line in output_lines:
        obj_pass = re.match(r'case (.*) pass', line)
        obj_fail = re.match(r'case (.*) fail', line)
        if obj_pass:
            index_str = obj_pass.group(1)
            index = int(index_str) - 1
            print('case %s pass' % tags[index])
        elif obj_fail:
            index = int(obj_fail.group(1)) - 1
            print('case %s fail' % tags[index])
