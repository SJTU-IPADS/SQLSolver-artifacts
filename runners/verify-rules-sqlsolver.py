#!/usr/bin/python3
import os
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-tests', action='store', required=True, help='Specify the test set. Possible values: wetune, sqlsolver.')
    args = parser.parse_args()
    # print(args)
    os.chdir('../sqlsolver')
    os.environ['LD_LIBRARY_PATH'] = os.path.join(os.getcwd(), 'lib')
    os.system("gradle :verifier:run --args='PlanTemplateVerifier -t={}'".format(args.tests))
