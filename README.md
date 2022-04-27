# Hello C++ gRPC standalone example

Here is extracted Hello C++ gRPC example
from https://github.com/grpc/grpc/tree/master/examples/cpp/helloworld

There are now two ways how to build this package:
1. using `cmake` and RPM packages ins openSUSE 15.3
1. or using Bazel build utility

## Setup using Bazel build tool
Based on:
- https://grpc.io/blog/bazel-rules-protobuf/

Unfortunately gRPC (that we use) is strongly dependent on Bazel Version:
- this repo can be build only with Bazel < 5
- latest gRPC repo can be build with Bzel 5+

Therefore I strongly recommend [Bazelisk](https://github.com/bazelbuild/bazelisk) wrapper
that will use Bazel version pinned in `.bazelversion` file.

Here is example Bazelisk setup common for all OS:

- download latest Bazelisk release from https://github.com/bazelbuild/bazelisk/releases
- download binary for your OS and rename it to `bazel` (or `bazel.exe` under Windows) and put it somewhere in your `PATH`

Example Bazelisk setup for Linux:
- ensure that you have installed curl and git
  ```bash
  # on openSUSE LEAP 15.3
  sudo zypper in git-core curl
  # on Fedora 35
  sudo dnf install git-core curl
  # on Ubuntu 20.04.4 LTS or Debian 11 (bullseye)
  sudo apt-get install git-core curl
  ```
- now download and install Bazelisk (as `bazel` executable)
  using commands:
  ```bash
  mkdir -p ~/bin
  curl -fL -o ~/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.11.0/bazelisk-linux-amd64
  chmod +x ~/bin/bazel
  ```
- under some distribution you may need to reload shell or add `~/bin` to `PATH`
  ```bash
  # required on Ubuntu 20.04.4 LTS and Debian 11 (bullseye)
  source ~/.profile
  ```
- ensure that you are using your Bazelisk (named as `bazel`):
  ```bash
  which bazel

  /home/$USER/bin/bazel
  ```

You also have to install C++ compiler (required by our example
and underlying libraries). Use following commands:
```bash
# for openSUSE LEAP 15.3 - tested GCC 7.5.0
sudo zypper in gcc-c++ gcc
# on Fedora 35 - tested GCC 11.2.1
sudo dnf install gcc-c++
# for Ubuntu 20.04 LTS - tested GCC 9.4.0
# and for Debian 11 (bullseye) - tested GCC 10.2.1
sudo apt-get install g++
```

Windows Notes:
- we have to follow: https://docs.bazel.build/versions/main/install-windows.html
- Under Windows you have to install MSVC 2019 + Windows SDK 10.
- Please note that Bazel 4.2.2, that is used for this project seems
  to not work with MSVC 2022 (but works OK with MSVC 2019).
- to avoid this error:
  ```
  ERROR: C:/projects/grpc-hello-cpp/BUILD:14:14:
     Compiling protoc outputs for ["helloworld.proto"] failed: (Exit -1):
     bash.exe failed: error executing command
       c:/tools/msys64/usr/bin/bash.exe -c set -euo pipefail
  ```
- you have to install MSYS2 into above hardcoded location:
  - download MSYS2 package:
    - https://github.com/msys2/msys2-installer/releases/download/2022-03-19/msys2-x86_64-20220319.exe
  - run installer and override installation
    path `c:\msys64` to `c:\toos\msys64` (!)
- now run MSYS terminal and (following Bazel installation guide)
  run this command:
  ```
  pacman -S zip unzip patch diffutils git
  ```
- confirm installation/upgrade of packages.
- now you can proceed with build instructions below...



Now checkout this source (valid for both Linux
and Windows with `GIT Bash` window):
```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/hpaluch-pil/grpc-hello-cpp.git
cd grpc-hello-cpp
```

And finally invoke build:
```bash
# Linux
bazel build //\:greeter_server //\:greeter_client
# CMD.exe - do NOT use GIT bash
bazel build //:greeter_server //:greeter_client
```
On openSUSE there were total 1993 Bazel actions and it took
around 45 minutes to build (1 CPU, 1GB RAM).

On Ubuntu 20.04.4 LTS there were 1669 actions and it took
around 39 minutes (2 CPU cores, 2GB RAM).

Compiled binaries are symlinked here:
- `bazel-bin/greeter_client`
- `bazel-bin/greeter_server`

You can run server using:
```
bazel run //:greeter_server
```
And on another terminal run client using:
```
bazel run //:greeter_client
```

NOTES:
- can't use now deprecated
  - https://github.com/pubref/rules_protobuf
  - Because of FileType error
- this one is better if you ignore most of official docs and rather
  copy content of theirs WORKSPACE and BUILD files...
  - https://github.com/stackb/rules_proto

WARNING! I had no luck building it on Fedora 35 with GCC 11.2.1 - type mismatch
errors on boringssl library:
```
ERROR: ~/.cache/bazel/_bazel_ansible/960abfbfa73fa3cbca4c58830056b902/external/boringssl/BUILD:131:11:
    Compiling src/crypto/fipsmodule/bcm.c failed: (Exit 1):
     gcc failed: error executing command /usr/bin/gcc -U_FORTIFY_SOURCE -fstack-protector
          -Wall -Wunused-but-set-parameter -Wno-free-nonheap-object
          -fno-omit-frame-pointer -MD -MF ... (remaining 34 argument(s) skipped)

In file included from external/boringssl/src/crypto/fipsmodule/bcm.c:38:
external/boringssl/src/crypto/fipsmodule/bn/asm/x86_64-gcc.c:427:51: error:
    argument 2 of type 'const uint64_t[8]' {aka 'const long unsigned int[8]'}
     with mismatched bound [-Werror=array-parameter=]
  427 | void bn_sqr_comba8(BN_ULONG r[16], const BN_ULONG a[8]) {
      |                                    ~~~~~~~~~~~~~~~^~~~
In file included from external/boringssl/src/crypto/fipsmodule/bn/add.c:64,
                 from external/boringssl/src/crypto/fipsmodule/bcm.c:37:
external/boringssl/src/crypto/fipsmodule/bn/internal.h:300:51: note: previously declared as 'const uint64_t[4]' {aka 'const long unsigned int[4]'}
  300 | void bn_sqr_comba8(BN_ULONG r[16], const BN_ULONG a[4]);
      |                                    ~~~~~~~~~~~~~~~^~~~
```
More details:
```
$ bazel query 'kind(http_archive, //external:boringssl)'

//external:boringssl
```
And more interesting:
```
bazel query --output build 'deps(//external:boringssl)'

# /home/ansible/projects/grpc-hello-cpp/WORKSPACE:59:10
http_archive(
  name = "boringssl",
  generator_name = "boringssl",
  generator_function = "grpc_deps",
  urls = ["https://storage.googleapis.com/grpc-bazel-mirror/github.com/google/boringssl/archive/067cfd92f4d7da0edfa073b096d090b98a83b860.tar.gz", "https://github.com/google/boringssl/archive/067cfd92f4d7da0edfa073b096d090b98a83b860.tar.gz"],
  sha256 = "6312f3785ccbbb45f190c1c8877d1b10f41420e3bb65ca5d14b8061621431136",
  strip_prefix = "boringssl-067cfd92f4d7da0edfa073b096d090b98a83b860",
)
# Rule boringssl instantiated at (most recent call last):
#   /home/ansible/projects/grpc-hello-cpp/WORKSPACE:59:10                                                                               in <toplevel>
#   /home/ansible/.cache/bazel/_bazel_ansible/960abfbfa73fa3cbca4c58830056b902/external/com_github_grpc_grpc/bazel/grpc_deps.bzl:150:21 in grpc_deps
# Rule http_archive defined at (most recent call last):
#   /home/ansible/.cache/bazel/_bazel_ansible/960abfbfa73fa3cbca4c58830056b902/external/bazel_tools/tools/build_defs/repo/http.bzl:336:31 in <toplevel>
```
Similar problems probably reported here:
- https://github.com/envoyproxy/envoy/issues/18816
- referenced commit (that failes on GCC 11) is such:
  - https://github.com/google/boringssl/commit/067cfd92f4d7da0edfa073b096d090b98a83b860
  - `BoringSSL Robot committed on Feb 5, 2021`
- fix commit (from above Issue):
  - https://boringssl.googlesource.com/boringssl/+/92c6fbfc4c44dc8462d260d836020d2b793e7804
  - mirror:
  - https://github.com/google/boringssl/commit/92c6fbfc4c44dc8462d260d836020d2b793e7804
  - `pefoley2 authored and CQ bot account: commit-bot@chromium.org committed on Jun 1, 2021`


### Setup with cmake

Tested OS: `openSUSE LEAP 15.3`/`x86_64`

Install these packages:
```bash
sudo zypper in git-core gcc-c++ gcc
sudo zypper in cmake cmake-full grpc-devel protobuf-devel libprotobuf-c-devel
```

Now checkout this source:
```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/hpaluch-pil/grpc-hello-cpp.git
cd grpc-hello-cpp
```

Now you can build binaries using standard cmake commands:
```bash
rm -rf ~/tmp/build-grpc
mkdir -p ~/tmp/build-grpc
cmake -B ~/tmp/build-grpc
make -C ~/tmp/build-grpc VERBOSE=1
```
Now in one terminal run server:
```bash
~/tmp/build-grpc/greeter_server
```
In another one run client:
```bash
~/tmp/build-grpc/greeter_client
```
You should see debug messages on both client and server.



## Exploring Server reflection

This Google's example includes Server reflection that
allows introspection of services by gRPC clients as described
on https://grpc.github.io/grpc/cpp/md_doc_server_reflection_tutorial.html

However it seems that openSUSE 15.3 does not include `grpc_cli` client,
so we have to build it ourselves:
- install:
  ```bash
  sudo zypper in grpc-source bazel python-devel python-xml
  ```
- these RPM packages were used:
  ```
  bazel3.4-3.4.1-bp153.2.1.x86_64
  grpc-source-1.25.0-3.2.2.noarch
  python-xml-2.7.18-150000.38.2.x86_64
  ```

- to build it with bazel tool:
  ```bash
  cd /usr/src/grpc/test/cpp/util
  # may try: "bazel query ..." to see targets in current dir
  bazel build //test/cpp/util:grpc_cli 
  ```
- now wait around 30minutes...
- and notice last few lines of output:
  ```
Target //test/cpp/util:grpc_cli up-to-date:
  /home/ansible/.cache/bazel/_bazel_ansible/7823a61af4ef74a2c6\
  09c17362cff8ed/execroot/com_github_grpc_grpc/bazel-out/\
  k8-fastbuild/bin/test/cpp/util/grpc_cli
  ```
- and rather copy above path to something like `/usr/local/bin`...

Now we can follow instructions 
from: https://grpc.github.io/grpc/cpp/md_doc_server_reflection_tutorial.html

On one terminal run example server:
```bash
~/tmp/build-grpc/greeter_server

Server listening on 0.0.0.0:50051
```

On another terminal query our service using:
```bash
$ grpc_cli ls 127.0.0.1:50051

helloworld.Greeter
grpc.reflection.v1alpha.ServerReflection
grpc.health.v1.Health

$ grpc_cli ls 127.0.0.1:50051 helloworld.Greeter

SayHello

# add -l to see more details on RPC call:
$ rpc_cli ls 127.0.0.1:50051 helloworld.Greeter -l

filename: helloworld.proto
package: helloworld;
service Greeter {
  rpc SayHello(helloworld.HelloRequest) returns (helloworld.HelloReply) {}
}

# to see argument(s) we have to send we can use "type" command:
$ grpc_cli type 127.0.0.1:50051 helloworld.HelloRequest

message HelloRequest {
  string name = 1;
}

$ grpc_cli call 127.0.0.1:50051 SayHello "name: '$USER'"

connecting to 127.0.0.1:50051
message: "Hello ansible"

Rpc succeeded with OK status
```

And that's all!

## Notes

Most of the grpc(++) detection code is from this package:
```bash
sudo zypper in rpm-build
sudo zypper si lightstep-tracer-cpp
sudo chown $USER:users /usr/src/packages/BUILD
rpmbuild -bp  /usr/src/packages/SPECS/lightstep-tracer-cpp.spec
# and look into /usr/src/packages/BUILD/lightstep-tracer-cpp-0.8.1/
```

There is one problem regarding openSUSE:
- gRPC(++) is available as `pkg-config` only
Thus this cmake build will not work under Windows. Hopefully
SUSE will someday provide cmake package files for both packages.

NOTE: Although there is no Protobuf's cmake package provided
by `protobuf-devel`, it is actually provided by `make-full` rpm package.
So the `find_package(Protobuf REQUIRED)` works without problem.

