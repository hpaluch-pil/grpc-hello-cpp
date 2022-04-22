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
sudo zypper in git-core cmake cmake-full gcc-c++ gcc grpc-devel protobuf-devel libprotobuf-c-devel
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
so the `find_package(Protobuf REQUIRED)` works...

