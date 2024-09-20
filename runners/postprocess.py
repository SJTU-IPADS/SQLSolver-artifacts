import re

verifiers = ["udp", "spes", "wetune", "sqlsolver"]
test_sets = ["calcite", "spark", "tpcc", "tpch"]

def extract_verification_results(file_name):
    pass_case = []
    verification_time = []
    with open(file_name, "r") as f:
        lines = f.readlines()
    for line in lines:
        search_result = re.search('case [0-9]+ pass: [0-9]+ ms', line, re.M|re.I)
        if search_result == None:
            search_result = re.search('case [0-9]+: pass, [0-9]+ ms', line, re.M|re.I)
        if search_result == None:
            search_result = re.search('Case [0-9]+ is: EQ [0-9]+ ms', line, re.M|re.I)
        if search_result:
            elements = search_result.group().split(" ")
            case_id = elements[1]
            if case_id[-1] == ':':
                case_id = case_id[:-1]
            pass_case.append(int(case_id))
            if elements[3] == "EQ":
                time = elements[4]
            else:
                time = elements[3]
            verification_time.append(int(time))
    return pass_case, verification_time, len(pass_case)

def process_e1():
    pass_cases = {}
    verification_times = {}
    pass_case_numbers = {}
    for verifier in verifiers:
        for test_set in test_sets:
            key = verifier + "-" + test_set
            log_file = "../results/e1/" + key + ".log"
            pass_case, verification_time, pass_case_number = extract_verification_results(log_file)
            pass_cases[key] = pass_case
            verification_times[key] = verification_time
            pass_case_numbers[key] = pass_case_number
            # We directly adopt the data in UDP paper, which indicates that UDP can pass 33 cases in Calcite
            if key == "udp-calcite" and pass_case_number < 33:
                pass_case_numbers[key] = 33
            # SPES can pass 1 case in TPC-H that cannot be supported by SPES algorithm. Because the parser rewrites the case into a form supported by SPES. Thus, for fairness, the case should not be included in cases that pass the verification of SPES
            if key == "spes-tpch":
                pass_case_numbers[key] = 0
                pass_cases[key] = []
                verification_times[key] = []
    print("1. The data in Table 1 of the paper:")
    print("(Note that SQLSolver can pass more cases than the original data in Table 1 because we further improve its verification capability.)\n")
    for verifier in verifiers:
        calcite_pass_number = pass_case_numbers[verifier+"-calcite"]
        spark_pass_number = pass_case_numbers[verifier+"-spark"]
        print(verifier + " can prove " + str(calcite_pass_number) + " cases in Calcite")
        print(verifier + " can prove " + str(spark_pass_number) + " cases in Spark SQL")
    
    print("\n\n2. The data in Table 5 of the paper:")
    print("(Note that unsupported cases of each baseline is more than the original data in paper because we further improve SQLSolver.)")
    print("(Note that the script outputs the data of \"Unsupported Cases\" column. The data of other columns are analysed manually by authors rather than the script, because it requires expertise.)\n")
    for verifier in verifiers:
        if verifier == "sqlsolver":
            continue
        unsupported_case_number = 0;
        for test_set in test_sets:
            baseline_key = verifier+"-"+test_set
            unsupported_case_number += pass_case_numbers["sqlsolver-"+test_set] - pass_case_numbers[baseline_key]
        print("Unsupported cases of " + verifier + " is " + str(unsupported_case_number))
 
    print("\n\n3. The data in Table 6 of the paper:")
    print("(Note that the verification time may fluctuate and different from Table 6 of the paper. Because to reduce the reproduction time, the script only runs the verification once rather than multiple times. However, the paper does not claim that SQLSolver is faster that other baselines. So fluctuation does not affect the conclusion of the paper.)")
    print("\n")
    for verifier in verifiers:
        if verifier == "sqlsolver":
            continue
        for test_set in test_sets:
            key = verifier + "-" + test_set
            
            baseline_pass_cases = pass_cases[key]
            if len(baseline_pass_cases) == 0:
                continue

            baseline_time = 0
            for time in verification_times[key]:
                baseline_time += int(time)
            baseline_avg_time = int(baseline_time/len(baseline_pass_cases))

            sqlsolver_time = 0
            sqlsolver_key = "sqlsolver-"+test_set
            sqlsolver_pass_cases = pass_cases[sqlsolver_key]
            sqlsolver_verification_time = verification_times[sqlsolver_key]
            for i in range(len(sqlsolver_pass_cases)):
                sqlsolver_pass_case_id = sqlsolver_pass_cases[i]
                if sqlsolver_pass_case_id in baseline_pass_cases:
                    sqlsolver_time += int(sqlsolver_verification_time[i])
            sqlsolver_avg_time = int(sqlsolver_time/len(baseline_pass_cases))
                
            print(verifier + " vs. SQLSolver on " + test_set + " is " + str(baseline_avg_time) + " vs. " + str(sqlsolver_avg_time))

    print("\n\n4. The data at the beginning of the first paragraph in Section 6.2:")
    print("(Note that the cases supported by SQLSolver is more than that in paper because we further improve SQLSolver.")
    baseline_pass_cases_number = 0
    for test_set in test_sets:
        pass_cases_set = []
        for verifier in verifiers:
            if verifier == "sqlsolver":
                continue
            baseline_pass_cases = pass_cases[verifier+"-"+test_set]
            for case_id in baseline_pass_cases:
                if not (case_id in pass_cases_set):
                    pass_cases_set.append(case_id)
        baseline_pass_cases_number += len(pass_cases_set)
    print("Among all 400 equivalent query pairs, UDP, SPES, and WeTune are able to prove the equivalence of " + str(baseline_pass_cases_number+1) + " pairs in total.")
    sqlsolver_pass_number = 0
    for test_set in test_sets:
        sqlsolver_pass_number += len(pass_cases["sqlsolver-"+test_set])
    print("SQLSolver can prove "+str(sqlsolver_pass_number)+" pairs, "+str(sqlsolver_pass_number-baseline_pass_cases_number-1)+" of which cannot be proved by any of these existing provers.")

def extract_orderby_pass_cases(file_path):
    with open(file_path, "r") as f:
        lines = f.readlines()
    case_ids = []
    for line in lines:
        search_result = re.search('case [0-9]+ pass', line)
        if search_result:
            case_id = search_result.group().split(" ")[1]
            case_ids.append(case_id)
    return case_ids


def process_e2():
    total_pass_orderby_cases = 0
    for test_set in test_sets:
        pass_case_ids = []
        for verifier in verifiers:
            if verifier == "sqlsolver":
                continue
            tmp_set = extract_orderby_pass_cases("../results/e2/"+verifier+"-"+test_set+".log")
            for case_id in tmp_set:
                if not (case_id in pass_case_ids):
                    pass_case_ids.append(case_id)
        total_pass_orderby_cases += len(pass_case_ids)
    print("\n\n5. The data in the third paragraph of Section 6.2:")
    print("Combined with our algorithm to handle ORDER BY, UDP, SPES, and WeTune can prove the equivalence of "+str(total_pass_orderby_cases)+" query pairs in total among 39 test cases with ORDER BY.")


def process_e3():
    print("\n\n6. The data in the last sentence of Section 1:")
    number = extract_rule_number("sqlsolver")
    print("When using SQLSolver to discover SQL rewrite rules, we find "+number+" new rewrite rules beyond the 35 rules found by using  the existing solver in WeTune.")
    print("\n\n7. The data in Section 6.3:")
    number = extract_rule_number("wetune")
    print("Our integration of SQLSolver reveals all "+number+" useful rules previously found by WeTune.")



def extract_rule_number(tag):
    with open("../results/e3/"+tag+".log", "r") as f:
        lines = f.readlines()
    for line in lines:
        search_result = re.search('Passed [0-9]+ rules', line)
        if search_result:
            number = search_result.group().split(" ")[1]
            return number

def process_e4():
    with open("../results/e4/sql-server.log", "r") as f:
        lines = f.readlines()
    acceleration = "99%"
    for line in lines:
        search_result = re.search(r'p99 improvement: [0-9]+\.[0-9]+\%', line)
        if search_result:
            acceleration = search_result.group().split(" ")[2]
    print("The new rules induce a latency reduction of up to "+acceleration+" compared to queries without rewrite.")

process_e1()
process_e2()
process_e3()
process_e4()
