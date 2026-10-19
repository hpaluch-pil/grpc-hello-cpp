#!/bin/bash
# native build (Target = Host)
set -euo pipefail
args=
build_type='Release'
make_args=
grpc_install_dir=

errx () { echo "ERROR: $*" >&2; exit 1; }

usage ()
{
	[ $# -lt 1 ] || [ -z "$1" ] || echo "ERROR: $1" >&2
	echo
	echo "Usage: $0 [ --grpc-install-dir /opt/grpc-v1.82.0/x86_64-redhat-linux  ] [ --build-type Debug | Release | MinSizeRel | RelWithDebInfo ][ --make-args ARGS ]" >&2
	echo "Default --build-type is: $build_type"
	echo "Example: $0 --make-args -j\`nproc\`"
	exit 1
}

while [ $# -gt 0 ]
do
	case "$1" in
		-h|--help)
			usage
			;;
		--build-type)
			case "$2" in
				Debug|Release|MinSizeRel|RelWithDebInfo)
					build_type="$2"
					shift
					;;
				*)
					usage "Invalid build type '$2'"
					;;
			esac
			;;
		--grpc-install-dir)
			grpc_install_dir="$2"
			[ -n "$grpc_install_dir" ] || errx "--grpc-install-dir requires argument"
			shift
			[ -d "$grpc_install_dir" ] || errx "grpc_install_dir='$grpc_install_dir' is not directory"
			f="$grpc_install_dir/lib/libgrpc++.a"
			[ -f "$f" ] || errx "grpc_install_dir='$grpc_install_dir' is not gRPC installation, because '$f' does not exist"
			;;
		--make-args)
			make_args="$2"
			shift
			;;
		*)
			usage "Invalid option \"$1\""
			;;
	esac
	shift
done

if [ -n "$grpc_install_dir" ]; then
	# we will use CMAKE configurations
	args="$args -DCMAKE_PREFIX_PATH=$grpc_install_dir/lib"
	PATH="$grpc_install_dir/bin:$PATH"
else
	# system install will use pkg-config tool - often required for Protobuf (missing *.cmake configs)
	args="$args -DUSE_PKG_CONFIG=ON"
fi

args="$args -DCMAKE_BUILD_TYPE=$build_type"
src=$( readlink -f $( dirname $0 ) )
cd "$src"
echo "Sources are in: `pwd`"
set -x
# always use hardcoded prefix to avoid disaster (rm -rf /) when variable is empty
rm -rf cmake/build
mkdir -p cmake/build
set +x
echo "Source directory: $src"
echo "Build directory : cmake/build"
set -x
cd cmake/build
cmake $args ../../
make VERBOSE=1 $make_args
set +x
echo "Build finished in: `pwd`"
exit 0
