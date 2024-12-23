# SQLSolver: Proving Query Equivalence Using Linear Integer Arithmetic

This repository provides all materials for [ACM SIGMOD 2024 ARI](https://reproducibility.sigmod.org/2024/index.html), including the source code and scripts of [SQLSolver](https://dl.acm.org/doi/pdf/10.1145/3626768) (SIGMOD 2024) as well as the baselines compared with it in our paper. SQLSolver is an automated prover for the equivalence of SQL queries. It proposes a new linear integer arithmetic theory to model the semantics of SQL queries and achieve automated verification via SMT solvers. Compared to prior provers, it can support more SQL features and has a stronger verification capability.

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

Note that this is a blocking process. If you see the following output in the terminal, the container has successfully started.

```
This is an informational message only. No user action is required.
```

Please open a new terminal and execute the following commands.

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

Results will be stored in the file `/app/results/reproduction.txt` inside the container.
You may also access the results outside the container in the `results` directory under the project root directory.
(`/app` is mapped to the project root directory)



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

## Online Demo

We provide an online [demo](https://sqlsolver.systems/sqlsolver/home) and you can try it. Note that the online demo runs on a machine with poor performance. If you want to reproduce all evaluation results, please use an AWS EC2 c5a.8xlarge machine with 128GB gp3 or a stronger machine.



## The Old Version of SQLSolver

After the paper was published, we further add some optimizations to SQLSolver, which aim at enhancing the verification capabilities. These optimizations, however, affect the speed of verification. Please note that even without these optimizations, SQLSolver can still verify all the test cases that we assert it can pass in the paper.

### Comparision of Two versions of SQLSolver

This repository provides the latest version of SQLSolver, while the old version of SQLSolver can be found in [this repository](https://github.com/nhaorand/ARI-Supplementary-Material.git). The main difference between this two versions of SQLSolver is that the new version has stronger verification capabilities but slower verification speed than the old version. For example, for the test cases from Spark SQL, the new version can pass 118 cases, while the old version can pass 114 cases.

### How to Run the Old Version of SQLSolver

Note that the old version is only accessible for SIGMOD ARI. If you want to use the latest version of SQLSolver, please visit this [repository](https://github.com/SJTU-IPADS/SQLSolver/).

Under the root directory of this repository, please first download the repository of the old SQLSolver.

```shell
git clone https://github.com/nhaorand/ARI-Supplementary-Material.git
```

Then, please enter the docker by the following command.

```shell
docker exec -it sqlsolver /bin/bash
```

Now, you are under the `/app` directory. Please enter the directory of the old SQLSolver.

```shell
cd ARI-Supplementary-Material
```

Run the `all-in-one.sh` and the reproduced results will be recorded in `./results/reproduction.txt`. 

```shell
./all-in-one.sh
```

You will find that the number of proved cases and the verification speed are compatible with the data in the paper.
