#!/bin/bash
set -xeuo pipefail
WS=$HOME/tmp/build-grpc
cd $( dirname $0 )
# use hardcoded path to avoid catastrophe (typo in variable)
rm -rf ~/tmp/build-grpc
mkdir -p $WS
cmake -B $WS
make -C $WS VERBOSE=1
exit 0

