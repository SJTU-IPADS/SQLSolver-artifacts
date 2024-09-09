# SQLSolver-AE

## Prerequisites

### Hardware requirements

The architecture should be `amd64` / `x64`.

We do all the experiments on an AWS EC2 c5a.8xlarge machine.

### Software requirements

OS: Ubuntu 22.04.4 LTS.
Other systems are not tested.

Docker along with `docker compose` should be installed. You may refer to the next section to install them.

Other software are containerized or embedded in the repository:
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

## Compile

The baselines `UDP` and `SPES` require compilation beforehand.

### Outside the container

In the project root directory, type:
```sh
# Pre-build binaries for UDP
# It pulls another docker image to help build the binaries, so we do this build outside the container
./build-udp.sh
```

### Inside the container

Enter the container by `docker exec -it sqlsolver /bin/bash`.
Then type:
```sh
# Pre-build binaries for SPES
./build-spes.sh
```

The rest of instructions assume that you have entered the container by `docker exec -it sqlsolver /bin/bash`
and you are at the directory `/app`.

## The master script

To do all the experiments with one click, type in the `/app` directory:
```sh
./all-in-one.sh
```

Results will be stored in `/app/results` inside the container.
You may also access the results outside the container in the `results` directory under the project root directory.
(`/app` is mapped to the project root directory)

Each of the directories in `/app/results` corresponds to an experiment below.
- Log files are available in all the experiments and record all the results.
- In addition, the first experiment (i.e. SQL equivalence benchmarks) also provides `.tsv` files.
Each `<verifier>-<benchmark>.tsv` file records the verification time of a verifier on one benchmark,
	the i-th line in the file shows the verification time of the i-th query pair in milliseconds,
	and an empty line indicates that the verifier fails to verify the query pair.

## Details of scripts for different experiments

All these scripts are in the `/app/runners` directory.

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

### Discovery of rules

In the `/app/runners` directory, type:
```sh
python verify-rules-sqlsolver.py -tests TESTS
# -tests TESTS: specify the benchmark; possible values are "wetune" and "sqlsolver".
```

### Compare the query latency before and after rewrite

In the `/app/runners` directory, type:
```sh
python run-useful-rewrite-example.py
```

## Explanation of absent figures

The number of Calcite test cases that UDP passes is taken from the UDP paper since we cannot reproduce this number.
We have tried out best to reproduce the result.
You can see that our script produces a lower number.

The analysis of why other verifiers fail to prove query equivalence are obtained by manual inspection,
so related figures (e.g. Table 5) are not available from automated scripts.

Some figures (e.g. Table 6) are not directly available from the results.
They need to be derived from the running results using tools like Microsoft Excel.

## Time cost estimation

The preparation before running the experiments, including building the docker image and compiling the code,
takes roughly 10 minutes under a good network condition.

The experiments take about 1.5 hours in all.
