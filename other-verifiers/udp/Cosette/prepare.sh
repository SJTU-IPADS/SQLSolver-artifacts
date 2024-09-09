#!/bin/bash

DIR="/Cosette-Dev"
# the command to build and test solver
CMD="cd dsl; cabal install HUnit; cabal install Parsec; cabal build; cd .." #; python solver_test.py"
NAME="cosette-test"

echo "[1] pulling the required docker image ..."
docker pull shumo/cosette-frontend

echo "[2] building Cosette in the docker container $NAME ..."
docker run -v $(pwd)/:$DIR -w $DIR --name=$NAME -it shumo/cosette-frontend bash -c "$CMD"

echo "[3] move LeanCodeGen into the right place ..."
cp dsl/dist/build/LeanCodeGen/LeanCodeGen uexp/src/uexp/run

echo "[4] remove the container ..."
docker rm $NAME

