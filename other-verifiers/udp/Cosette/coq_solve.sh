#!/bin/bash

NAME=Cosette

BUILD=.build_solve

FILE="$1"

UUID=$(head /dev/urandom | tr -dc A-Za-z | head -c 13 )


mkdir -p hott/$BUILD
mkdir -p .compiled/

cp $FILE hott/$BUILD/$UUID.v
cp hott/$BUILD/$UUID.v .compiled/
cd hott/
cp -n -r library $BUILD/
cd $BUILD; (find ./library -name '*.v'; echo "./$UUID.v") | xargs coq_makefile -R . $NAME -o MakefileSolve_$UUID
sed -i "s/coq/hoq/" MakefileSolve_$UUID
make -j4 -f MakefileSolve_$UUID
rm $UUID.*
rm MakefileSolve_$UUID
