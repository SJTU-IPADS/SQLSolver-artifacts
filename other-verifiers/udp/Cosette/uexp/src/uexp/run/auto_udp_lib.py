# python2

from subprocess import Popen, PIPE, STDOUT
import re
import os
import time

# constants (configurable)

## LEAN_BIN: the path to the Lean 3 executable; its full path can be omitted if it has been added to your environmental PATH
LEAN_BIN = 'lean'

## LEAN_CODE_GEN_BIN: the path to LeanCodeGen (built in the Cosette project)
LEAN_CODE_GEN_BIN = './LeanCodeGen'

## IMPORTS: the lean files that a generated lean file will import; needs no modification
IMPORTS = ['..sql', '..tactics', '..u_semiring', '..extra_constants', '..meta.TDP', '..meta.canonize', '..meta.ucongr', '..meta.cosette_tactics', '..meta.SDP', '..meta.UDP']

## PROOFS: the proof templates used in a generated lean file; needs no modification
PROOFS = [
    ['intros', 'try { unfold_all_denotations }', 'try { funext, simp }', 'try { TDP\' ucongr }', 'try { UDP }']
]

ROUNDS = 1

# variables

records_time = False
last_time_trans = 0
last_time_lean = 0
last_time_trans_avg = 0
last_time_lean_avg = 0

# functions

ic_args_count = {'unique': 2, 'foreign': 4}

# read ic from cos
def toIC(cos_str):
    # split
    words = re.split(r'[\(\), \t;]', cos_str)
    # decide ic type
    ic_type = words[0]
    # extract ic args
    ic_args = []
    for word in words[1:]:
        # filter out empty strings
        if word != '':
            ic_args.append(word)
    # check ic args count
    if len(ic_args) != ic_args_count[ic_type]:
        print('bad IC: expected %d args for IC %s, actual %d args' % (ic_args_count[ic_type], ic_type, len(ic_args)))
        return None
    # return: ic type, ic args
    return (ic_type, ic_args)

# whether input is ic
def isIC(cos_str):
    return re.match(r'(unique\((.*),(.*)\))|(foreign\((.*),(.*),(.*),(.*)\))', cos_str) != None

# millis time
def millis():
    return round(time.time() * 1000)

# names: existing names
# the generated name is in the form "prefixN" where N is a natural number
def freshName(names, prefix):
    i = 0
    new_name = prefix + str(i)
    while names.count(new_name) > 0:
        i += 1
        new_name = prefix + str(i)
    names.append(new_name)
    return new_name

# return an IC prop/type string
def IC2Str(ic, ic_name, key_refers):
    ic_type = ic[0]
    ic_args = ic[1]
    if ic_type == 'unique':
        rel = 'rel_' + ic_args[0]
        attr = ic_args[0] + '_' + ic_args[1]
        key_refers[(rel, attr)] = ic_name
        return 'isKey ' + attr + ' ' + rel
    elif ic_type == 'foreign':
        rel = 'rel_' + ic_args[0]
        attr = ic_args[0] + '_' + ic_args[1]
        rel_to = 'rel_' + ic_args[2]
        attr_to = ic_args[2] + '_' + ic_args[3]
        key_ic = key_refers[(rel_to, attr_to)]
        return 'fKey ' + attr_to + ' ' + attr + ' ' + rel_to + ' ' + rel + ' ' + key_ic

def insertICsInline(line, ics):
    names = []
    conds = re.split(r'[\(\)]', line)
    # conds[0] == 'forall '
    for pair in conds[1:]:
        first = pair.split(':')[0]
        new_names = first.split(' ')
        for name in new_names:
            if name != '':
                names.append(name)
    # the last char is a comma
    line_ic = line[:-1]
    key_refers = dict()
    for ic in ics:
        ic_name = freshName(names, ic[0])
        ic_str = ' ('
        ic_str += ic_name
        ic_str += ' : '
        ic_str += IC2Str(ic, ic_name, key_refers)
        ic_str += ')'
        line_ic += ic_str
    line_ic += ','
    return line_ic

# insert ic in lean
def insertICs(lean, ics):
    # find a line that starts with forall
    # we are gonna insert ICs at the end of this line
    lean_ic = ''
    lines = lean.split('\n')
    for line in lines:
        if line.startswith('forall'):
            lean_ic += insertICsInline(line, ics)
            lean_ic += '\n'
        else:
            lean_ic += line
            lean_ic += '\n'
    return lean_ic

def replaceImports(lean, imports):
    lean_r = ''
    lines = lean.split('\n')
    # remove old imports
    for line in lines:
        if not line.startswith('import'):
            lean_r += line
            lean_r += '\n'
    # add new imports
    import_str = ''
    for imp in imports:
        import_str += 'import ' + imp + '\n'
    return import_str + lean_r

def proof2Str(proof):
    s = ''
    for line in proof:
        s += '    '
        s += line
        s += ',\n'
    return s

def insertProof(lean, proof):
    lean_r = ''
    lines = lean.split('\n')
    # replace sorry with proof
    for line in lines:
        if line.count('sorry') < 1:
            lean_r += line
            lean_r += '\n'
        else:
            lean_r += proof2Str(proof)
            lean_r += '\n'
    return lean_r

def cos2Lean(cos, proof):
    global last_time_trans
    # recognize ic
    ics = []
    lcg_input = ''
    cos_lines = cos.split(';')
    for cos_str in cos_lines:
        cos_str = cos_str.strip()
        if isIC(cos_str):
            # record ic & remove from LCG input
            ics.append(toIC(cos_str))
        elif cos_str != '':
            # add to LCG input
            lcg_input += cos_str
            lcg_input += ';\n'
    # call LeanCodeGen without ic
    proc = Popen(LEAN_CODE_GEN_BIN, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
    time_start = millis()
    lcg_output = proc.communicate(input=lcg_input)[0]
    time_end = millis()
    last_time_trans = time_end - time_start
    # replace imports, insert ic, insert proof
    lean = insertProof(insertICs(replaceImports(lcg_output, IMPORTS), ics), proof)
    # insert proof in lean
    return lean

def generateLeanFile(cos_filename, lean_filename, proof):
    # read .cos file
    ofile = open(cos_filename)
    source = ofile.read().lower()
    ofile.close()
    # convert
    lean = cos2Lean(source, proof)
    # write .lean file
    ofile = open(lean_filename, 'w')
    ofile.write(lean)
    ofile.close()

def verifyLeanFile(lean_filename):
    global last_time_lean
    cmd = LEAN_BIN + ' ' + lean_filename
    proc = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
    time_start = millis()
    proc.communicate()
    time_end = millis()
    last_time_lean = time_end - time_start
    ret = proc.returncode
    return ret

def doFile(filename, lean_filename, proof):
    global last_time_trans
    if filename.endswith('.cos'):
        generateLeanFile(filename, lean_filename, proof)
    else:
        lean_filename = filename
        last_time_trans = 0
    return verifyLeanFile(lean_filename)

def tryProofs(filename, lean_filename, proofs):
    global last_time_trans_avg
    global last_time_lean_avg
    for proof in proofs:
        ret = doFile(filename, lean_filename, proof)
        if ret == 0:
            if records_time:
                time_sum_trans = last_time_trans
                time_sum_lean = last_time_lean
                for i in range(ROUNDS - 1):
                    doFile(filename, lean_filename, proof)
                    time_sum_trans = time_sum_trans + last_time_trans
                    time_sum_lean = time_sum_lean + last_time_lean
                last_time_trans_avg = time_sum_trans / ROUNDS
                last_time_lean_avg = time_sum_lean / ROUNDS
            return True
    return False

def getFileList(path):
    files = []
    for dirpath, dirnames, filenames in os.walk(path):
        filtered_files = list(filter((lambda f: f.endswith('.cos') or f.endswith('.lean')), filenames))
        new_files = list(map((lambda f: (f, dirpath)), filtered_files))
        files += new_files
    return files

# process a category of .cos/.lean files
def doCategory(cat_name, cat_path, case_tags):
    results = []
    success = 0
    total = 0
    files = getFileList(cat_path)
    files.sort()
    for f in files:
        casename = f[0]
        path = f[1]
        prefix = os.path.join(path, casename)
        filename = prefix
        lean_tmp = '_tmp.lean'
        # convert .cos to .lean & verify
        #print('Processing ' + prefix + '...')
        res = tryProofs(filename, lean_tmp, PROOFS)
        # record the result
        time_str = ''
        if records_time and res:
            time_str = ', %d ms' % (last_time_trans_avg + last_time_lean_avg)
            results.append((prefix, res, last_time_trans_avg, last_time_lean_avg))
        else:
            results.append((prefix, res, None, None))
        tag = prefix if case_tags is None else 'case ' + case_tags[total]
        print(tag + ': ' + ('pass' if res else 'fail') + time_str)
        # stats
        total += 1
        if res:
            success += 1
        # save .lean
        '''if filename.endswith('.cos'):
            lean_save = os.path.join(path, lean_save_dir, casename)
            if not res:
                lean_save += '_fail'
            lean_save += '.lean'
            os.system('cp ' + lean_tmp + ' ' + lean_save)'''
    return (results, success, total)

# [([(prefix, result, trans_avg, lean_avg)], success_count, total_count)]
# case_tags: for each case, file name -> tag name
def evaluate(categories, btime, case_tags_list=None):
    global records_time
    records_time = btime
    results_cats = []
    i = 0
    for cat_name, cat_path in categories:
        case_tags = None if case_tags_list is None else case_tags_list[i]
        i = i + 1
        results, success, total = doCategory(cat_name, cat_path, case_tags)
        result_filename = cat_name + '_result.txt'
        ofile = open(result_filename, 'w')
        ofile.write('%s %s: %d/%d\n' % (cat_name, cat_path, success, total))
        for prefix, res, trans_avg, lean_avg in results:
            ofile.write('%s %s\n' % (prefix, ('success' if res else 'failure')))
        ofile.close()
        print('%s: %d success out of %d cases' % (cat_name, success, total))
        results_cats.append((results, success, total))
    return results_cats

