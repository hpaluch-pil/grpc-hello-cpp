#!/bin/bash
set -xeuo pipefail
WS=$HOME/tmp/build/grpc-hello
cd $( dirname $0 )
# use hardcoded path to avoid catastrophe (typo in variable)
rm -rf ~/tmp/build/grpc-hello
mkdir -p $WS
cmake -B $WS
make -C $WS VERBOSE=1
exit 0

