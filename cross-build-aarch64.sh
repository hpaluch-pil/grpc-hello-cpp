#!/bin/bash
# cross-build this example for ARM aarch64
# gRPC and aarch64 toolchain must be already installed
# using: https://github.com/hpaluch-pil/grpc-build-scripts
set -euo pipefail
# gRPC version as /opt/grpc-VER
ver=v1.82.0
GCC_EXE=/opt/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc
GCC_EXE_HOST=gcc

errx () { echo "ERROR: $*" 2>&1; exit 1; }
MY_DIR=$( readlink -f $( dirname $0 ) )
# toolchain file
TC_FILE=$MY_DIR/cmake/toolchain_aarch64_gcc11.cmake
echo "INFO: Using CMake toolchain file '$TC_FILE'"
[ -f "$TC_FILE" ] || errx "Invalid toolchain pathname '$TC_FILE'"

INSTALL_BASEDIR=/opt/grpc-$ver
echo "INFO: Target install base directory: $INSTALL_BASEDIR"

[ -d "$INSTALL_BASEDIR" ] || errx "Target install base dir $INSTALL_BASEDIR does not exist"
MACH_HOST=$( $GCC_EXE_HOST -dumpmachine )
INSTALL_HOSTDIR=$INSTALL_BASEDIR/host-$MACH_HOST
[ -d "$INSTALL_HOSTDIR" ] || errx "Build Host install dir $INSTALL_HOSTDIR does not exist"
echo "INFO: Host build installation dir: $INSTALL_HOSTDIR"

MACH=$( $GCC_EXE -dumpmachine )
echo "INFO: Using cross GCC compiler $GCC_EXE machine $MACH"
INSTALL_TARGET=$INSTALL_BASEDIR/$MACH
echo "INFO: Target installation dir: $INSTALL_TARGET"

set -x
cd "$MY_DIR"
# we use hardcoded path to avoid disaster in case of typo
rm -rf "cmake/build-$MACH"
mkdir -p "cmake/build-$MACH"
pushd "cmake/build-$MACH"
PATH=$INSTALL_HOSTDIR/bin:$PATH
export PATH
cmake -DCMAKE_TOOLCHAIN_FILE=$TC_FILE \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=17 \
      -Dabsl_DIR=$INSTALL_TARGET/lib/cmake/absl \
      -DProtobuf_DIR=$INSTALL_TARGET/lib/cmake/protobuf \
      -Dutf8_range_DIR=$INSTALL_TARGET/lib/cmake/utf8_range \
      -DgRPC_DIR=$INSTALL_TARGET/lib/cmake/grpc \
      ../..
make VERBOSE=1 -j`nproc`
set +x
echo "Example binaries build in: `pwd`"
set -x
popd
exit 0

