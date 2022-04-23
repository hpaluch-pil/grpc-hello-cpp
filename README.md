# Hello C++ gRPC standalone example

Here is extracted Hello C++ gRPC example
from https://github.com/grpc/grpc/tree/master/examples/cpp/helloworld

This example show how to utilize RPM packages in openSUSE 15.3 to
build C++ gRPC client/server without need
to rebuild entire Protobuf and gRPC (as is in official Google's guide)

## Setup

Tested OS: `openSUSE LEAP 15.3`/`x86_64`

You need to install at least packages:
```bash
sudo zypper in git-core gcc-c++ gcc
```
Now checkout this source:
```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/hpaluch-pil/grpc-hello-cpp.git
cd grpc-hello-cpp
```

### Setup with cmake

Install these packages:
```bash
sudo zypper in cmake cmake-full grpc-devel protobuf-devel libprotobuf-c-devel
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

### Setup with Bazel

Experimental. Based on:
- https://grpc.io/blog/bazel-rules-protobuf/

Install these additional packages:
```bash
sudo zypper in bazel python-devel python-xml
```
This bazel version was tested:
```bash
$ bazel --version

bazel 3.4.1- (@non-git)
```

Now invoke this command to build client and server:
```bash
bazel build //\:greeter_server //\:greeter_client
```
To see all local target try this command:
```bash
bazel query ...
```
Compiled binaries are symlinked here:
- `bazel-bin/greeter_client`
- `bazel-bin/greeter_server`


NOTES:
- can't use now deprecated
  - https://github.com/pubref/rules_protobuf
  - Because of FileType error
- this one is better if you ignore most of official docs and rather
  copy content of theirs WORKSPACE and BUILD files...
  - https://github.com/stackb/rules_proto

WARNING! I had no luck building it on Fedora 35 - type mismatch
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
Similar problems probably reported here:
- https://github.com/envoyproxy/envoy/issues/18816
- https://boringssl.googlesource.com/boringssl/+/92c6fbfc4c44dc8462d260d836020d2b793e7804

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

