# python2

# Run UDP using calcite table schemas.

import argparse
import os
import shutil
import time

from auto_udp_lib import evaluate

env = ''

def millis():
    return round(time.time() * 1000)

def read_schema(filename):
    with open(filename, 'r') as ofile:
        return ofile.read()

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
        time_start = millis()
        cos = env + '\n\n' + 'query q1 `' + test[0] + '`;\nquery q2 `' + test[1] + '`;\nverify q1 q2;'
        filename = '{0:03d}.cos'.format(i)
        with open(os.path.join(path, filename), 'w') as ofile:
            ofile.write(cos)
        time_end = millis()
        gen_cos_times.append(time_end - time_start)
        i = i + 1
    return gen_cos_times

#
# eval_results = [(_, _, trans_avg, verif_avg)]
def merge_results(gen_cos_times, eval_results):
    results = []
    for gen_cos, eval_res in zip(gen_cos_times, eval_results):
        trans_avg = eval_res[2]
        verif_avg = eval_res[3]
        if (trans_avg != None and verif_avg != None):
            result = gen_cos + trans_avg + verif_avg
            results.append(int(result))
        else:
            results.append('')
    return results

def print_final_result(result, filename):
    #print('=====result starts=====')
    with open(filename, 'w') as f:
        for t in result:
            print >> f, t
    #print('=====result ends=====')

def main():
    global env
    parser = argparse.ArgumentParser(description='Run tests using Calcite table schemas.')
    parser.add_argument('--dir', action='store', default='tests/db_rule_instances', help='Specify the test directory.')
    parser.add_argument('--tests', action='store', default='spark_tests', help='Specify the test set.')
    parser.add_argument('--alias', action='store', default='spark', help='Specify the name of the test set.')
    parser.add_argument('--schema', action='store', default='schema_calcite', help='Specify the schema template file.')
    #parser.add_argument('--cos', action='store', default='calcite', help='Where .cos files are generated.')
    parser.add_argument('--regen', action='store_true', help='Do not use existing .cos files if set.')
    parser.add_argument('--time', action='store_true', help='Record running time statistics.')
    parser.add_argument('--tsv', action='store', default=None, help='Output running time into the specified file in .tsv format.')
    args = parser.parse_args()
    tests_file = os.path.join(args.dir, args.tests)
    env = read_schema(args.schema)
    tests = read_tests(tests_file)
    gen_cos_times = generate_cos_files(args.alias, args.regen, tests)
    tags = []
    for i in range(len(tests)):
        tags.append(str(i + 1))
    eval_ret = evaluate([(args.alias, args.alias)], args.time, [tags])
    if args.time and args.tsv:
        final_res = merge_results(gen_cos_times, eval_ret[0][0])
        print_final_result(final_res, args.tsv)

if __name__ == '__main__':
    main()
