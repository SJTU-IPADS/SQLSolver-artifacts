# python2

# Front end for .cos/.lean files (by default Calcite tests)

import argparse
import os
from auto_udp_lib import evaluate

def load_tags(tdir):
    tags = []
    with open(os.path.join(tdir, 'tags'), 'r') as ofile:
        tags = list(map(lambda s: s.strip(), ofile.readlines()))
    return tags

#
# eval_results = [(_, _, trans_avg, verif_avg)]
def merge_results(eval_results):
    results = []
    for eval_res in eval_results:
        trans_avg = eval_res[2]
        verif_avg = eval_res[3]
        if (trans_avg != None and verif_avg != None):
            result = trans_avg + verif_avg
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

# main

parser = argparse.ArgumentParser()
parser.add_argument('-name', action='store', default='calcite', help='Specify the test name.')
parser.add_argument('-dir', action='store', default='../calcite_cos_lean', help='Specify the test directory.')
parser.add_argument('-time', action='store_true', default=False)
parser.add_argument('-tsv', action='store', default=None, help='Output running time into the specified file in .tsv format.')
args = parser.parse_args()
tags = load_tags(args.dir)
eval_ret = evaluate([(args.name, args.dir)], args.time, [tags])
if args.time and args.tsv:
    final_res = merge_results(eval_ret[0][0])
    print_final_result(final_res, args.tsv)
