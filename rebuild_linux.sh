#!/bin/bash
set -euo pipefail
args=
build_type='Release'
make_args=
WORKSPACE=

errx () { echo "ERROR: $*" >&2; exit 1; }

usage ()
{
	[ $# -lt 1 ] || [ -z "$1" ] || echo "ERROR: $1" >&2
	echo
	echo "Usage: $0 [ --ws WORKSPACE ] [ --build-type Debug | Release | MinSizeRel | RelWithDebInfo ][ --make-args ARGS ]" >&2
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
		--ws)
			WORKSPACE="$2"
			shift
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

p=grpc-hello-$build_type

[ -n "$WORKSPACE" ] || {
	WORKSPACE=~/tmp
	mkdir -pv $WORKSPACE
}

[ -n "$WORKSPACE" -a -d "$WORKSPACE" ] || {
	echo "Internal error - $WORKSPACE is invalid" >&2
	exit 1
}

# always use hardcoded prefix to avoid disaster (rm -rf /) when variablei sempty
set -x
rm -rf $WORKSPACE/build/$p
mkdir -p $WORKSPACE/build/$p
set +x
args="$args -DCMAKE_BUILD_TYPE=$build_type"
src=$( readlink -f $( dirname $0 ) )
echo "Source directory: $src"
echo "Build directory : $WORKSPACE/build/$p"
set -x
cd $WORKSPACE/build/$p
cmake $args $src
make VERBOSE=1 $make_args
set +x
echo "Build finished in: `pwd`"
exit 0

