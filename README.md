# SQLSolver: Proving Query Equivalence Using Linear Integer Arithmetic

This repository provides the source code and scripts of SQLSolver (SIGMOD 2024) as well as the baselines compared with it in the paper. SQLSolver is an automated prover for the equivalence of SQL queries. It proposes a new linear integer arithmetic theory to model the semantics of SQL queries and achieve automated verification via SMT solvers. Compared to prior provers, it can support more SQL features and has a stronger verification capability.

## Prerequisites

### Hardware requirements

We do all the experiments on an AWS EC2 c5a.8xlarge machine with 128GB gp3.

### Software requirements

The operating system used is Ubuntu 20.04 LTS. Other systems are not tested.

Docker along with `docker compose` should be installed. You can install it by following the instruction of the next section.

Other software has been containerized or embedded in our repository. You do not need to install them.
- Python 3 and Python 2
- Java 17
- Maven 3.9.6
- Gradle 7.3.3
- Lean 3
- SQL Server 2022
- z3 4.13.0

### Install Docker with Compose

If you have not installed Docker, just use our script to finish the installation:
```sh
./install-docker.sh
```

Alternatively, you may follow instructions in [Install the Compose plugin](https://docs.docker.com/compose/install/linux/) to install Docker with `docker compose` support.

> If you have installed `docker.io` from `apt`, you may want to remove it and install `docker-ce` with the script. Type:
> ```sh
> sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
> # Delete all images, containers, and volumes
> sudo rm -rf /var/lib/docker
> sudo rm -rf /var/lib/containerd
> ```

> If you're running Linux in a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.

After that, you should be able to use Docker in non-root mode. To verify your installation, type:
```sh
docker compose version
# It should output a line like this:
# Docker Compose version v2.29.2
```

### Build the Docker image and start a container

In the project root directory, type:
```sh
docker compose up --remove-orphans
```

## Compilation

The baselines `UDP` and `SPES` require compilation beforehand.

### Compilation of UDP

To compile UDP, run the script `build-udp.sh` under the root directory:
```sh
# Pre-build binaries for UDP
# It pulls another docker image to help build the binaries, so we do this build outside the container
./build-udp.sh
```

### Compilation of SPES

To compile SPES, run the following command to enter the container firstly.

```shell
docker exec -it sqlsolver /bin/bash
```


Then run the script `build-spes.sh` under the `/app` directory inner the container:

```sh
# Pre-build binaries for SPES
./build-spes.sh
```



## Experimental Reproduction

Note that the following commands should be run after you enter the container by `docker exec -it sqlsolver /bin/bash`
and the current directory is `/app`.

To reproduce all the evaluation results in the paper, run the following command under the `/app` directory inner the docker:

```sh
./all-in-one.sh
```

Results will be stored in the log files under `/app/results` inside the container.
You may also access the results outside the container in the `results` directory under the project root directory.
(`/app` is mapped to the project root directory)

Each of the directories in `/app/results` corresponds to an experiment below.
- The files under`/app/results/e1` directory reproduce the evaluation results in Table 1 and Section 6.2.  The number of equivalent pairs that can be proved by each verifier is shown at the end of log files. For example, the following line at the end of `sqlsolver-calcite.log`indicates that SQLSolver can prove all 232 cases in Calcite test set.

  ```
  Passed 232 cases.
  ```

  Note that UDP paper said that it can prove 33 pairs of equivalent queries in the Calcite test set. However, since UDP does not release all its source code, `udp-calcite.log` cannot produce its original results on the Calcite test set. Thus, in our paper, we directly adopt the data in UDP paper rather than the data in `udp-calcite.log`.

  Table 5 in Section 6.2 shows the root causes that each verifier fail to prove some cases that can be proved by SQLSolver. Since the analysis of root causes requires expertise and has to be implemented manually, there is no automated scripts to generate this table.

  Additionally,  `/app/results/e1` also contains `.tsv` files. Each `<verifier>-<benchmark>.tsv` file records the verification time of a verifier on one benchmark, the i-th line in the file shows the verification time of the i-th query pair in milliseconds,
  and an empty line indicates that the verifier fails to verify the query pair. The data in Table 6 of the paper are manually calculated by tsv files.

- The files under `/app/results/e2 `directory reproduce the results in the third paragraph of Section 6.2. Each log file shows the number of cases that can be proved by baseline verifiers after combing them with our algorithm of handling `order by`.

- The files under `/app/results/e3` directory  reproduce the results in Section 6.3. `wetune.log` shows that SQLSolver can prove all 35 rewrite rules discovered by [WeTune](https://dl.acm.org/doi/10.1145/3514221.3526125).  `sqlsolver.log` shows that SQLSolver can prove another 42 rewrite rules.

- The files under `/app/results/e4` directory  reproduce the results in Section 6.3. `sql-server.log` shows the original query and the query after rewrite. It also shows the latency of two queries and calculate the acceleration.

## Details of scripts

All the scripts are in the `/app/runners` directory.

### Test on SQL equivalence benchmarks

#### SQLSolver

In the `/app/runners` directory, type:
```sh
python run-tests-sqlsolver.py -tests TESTS [-time]
# -tests TESTS: specify the benchmark; possible values are "calcite", "spark", "tpcc", and "tpch".
# -time: (optional) print the verification time (ms) of each test case.
```

#### Other verifiers

If you want to test the verifier `verifier` (possible values: `spes`, `udp`, `wetune`),
go to the `/app/runners` directory and type:
```sh
python run-tests-<verifier>.py -tests TESTS [-time]
# -tests TESTS: specify the benchmark; possible values are "calcite", "spark", "tpcc", and "tpch".
# -time: (optional) print the verification time (ms) of each test case.
```

### Combine the ORDER BY algorithm with other verifiers

If you want to test the verifier `verifier` (possible values: `spes`, `udp`, `wetune`),
go to the `/app/runners` directory and type:
```sh
python no-order-by-<verifier>.py -tests TESTS
# -tests TESTS: specify the benchmark; possible values are "calcite", "spark", "tpcc", and "tpch".
```

### Discovered Rewrite Rules

In the `/app/runners` directory, type:
```sh
python verify-rules-sqlsolver.py -tests TESTS
# -tests TESTS: specify the benchmark; possible values are "wetune" and "sqlsolver".
```

### Effectiveness of Discovered Rules

In the `/app/runners` directory, type:
```sh
python run-useful-rewrite-example.py
```



## Time Estimation of the Whole Workflow 

The preparation before running the experiments takes roughly 10 minutes, including building the docker image and compiling the code,

Running `all-in-one.sh` to reproduce all evaluation results will take about 1.5 hours.
