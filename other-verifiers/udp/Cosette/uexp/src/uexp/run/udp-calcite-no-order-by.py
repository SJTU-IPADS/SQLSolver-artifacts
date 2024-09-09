# python2

import argparse
import os
import shutil
import time

from auto_udp_lib import evaluate

env = ''

def read_tests(filename):
    ret = []
    with open(filename, 'r') as ofile:
        lines = ofile.read().split('\n')
        i = 0
        tmp = ''
        for line in lines:
            if not line.strip():
                continue
            if i % 2 == 0:
                tmp = line
            else:
                ret.append([tmp, line])
            i = i + 1
    return ret

def generate_cos_files(path, regen, tests):
    if os.path.exists(path):
        if regen:
            shutil.rmtree(path)
        else:
            print('The path of test cases "' + path + '" exists. Existing .cos files in that directory will be reused.')
            return
    os.makedirs(path)
    i = 1
    gen_cos_times = []
    for test in tests:
        cos = env + '\n\n' + 'query q1 `' + test[0] + '`;\nquery q2 `' + test[1] + '`;\nverify q1 q2;'
        filename = '{0:03d}.cos'.format(i)
        with open(os.path.join(path, filename), 'w') as ofile:
            ofile.write(cos)
        i = i + 1

def load_tags(tdir, tests):
    tags = []
    with open(os.path.join(tdir, 'tags_' + tests), 'r') as ofile:
        tags = list(map(lambda s: s.strip(), ofile.readlines()))
    return tags

def read_schema(filename):
    with open(filename, 'r') as ofile:
        return ofile.read()

def main():
    global env
    parser = argparse.ArgumentParser(description='Run tests using Calcite table schemas.')
    parser.add_argument('--dir', action='store', default='tests/no_order_by', help='Specify the test directory.')
    parser.add_argument('--tests', action='store', required=True, help='Specify the test set. Possible values: calcite, spark.')
    parser.add_argument('--schema', action='store', default='schema_calcite', help='Specify the schema template file.')
    parser.add_argument('--regen', action='store_true', help='Do not use existing .cos files if set.')
    args = parser.parse_args()
    tests_cat = args.tests + '_no_order_by'
    tests_file = os.path.join(args.dir, 'tests_' + args.tests)
    env = read_schema(args.schema)
    tests = read_tests(tests_file)
    generate_cos_files(tests_cat, args.regen, tests)
    tags = load_tags(args.dir, args.tests)
    eval_ret = evaluate([(tests_cat, tests_cat)], False, [tags])

if __name__ == '__main__':
    main()
