# Hello C++ gRPC standalone example

Here is extracted Hello C++ gRPC example
from https://github.com/grpc/grpc/tree/master/examples/cpp/helloworld

There are now two ways how to build this package:
1. using `cmake` and RPM packages in `openSUSE LEAP 15.3`
1. or using Bazel build utility - tested under openSUSE LEAP 15.3, Debian 11, Fedora 35
   and Windows 10 with MSVC 2019 Professional

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

WARNING! It was really difficult to find right commit in BoringSSL, that will:
- fix array bounds mismatches - so GCC will not terminate with error
- but still support older C++ standards (latest BoringSSL requires C++14(!)
- and still build using exiting gRPC base
Finally I found right version of BoringSSL  - see bottom or WORKSPACE
file for details

### Setup with cmake: Linux

Tested OS: `Fedora 44`

Install these packages:
```bash
sudo dnf group install c-development
sudo dnf install git-core grpc-devel cmake
```

Outdated:
> Tested OS: `openSUSE LEAP 15.3`/`x86_64`
> 
> Install these packages:
> ```bash
> sudo zypper in git-core gcc-c++ gcc
> sudo zypper in cmake cmake-full grpc-devel protobuf-devel libprotobuf-c-devel
> ```

Now checkout this source:
```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/hpaluch-pil/grpc-hello-cpp.git
cd grpc-hello-cpp
```

You can build binaries using prepared build script:
```bash
./rebuild_linux.sh
```
Now in one terminal run server:
```bash
~/tmp/build/grpc-hello/greeter_server
```
In another one run client:
```bash
~/tmp/build/grpc-hello/greeter_client
```
You should see debug messages on both client and server.
The `greeter_client` supports following optional arguments:
- `--target=REMOTE_IP:REMOTE_PORT` - connect to other gRPC server and port, default is `localhost:50051`
- `--repeat=NUMBER_OF_CALLS` - number of gRPC calls (loop), default is `1`

### Setup with CMake: cross-build aarch64

First you have to cross-build gRPC for aarch64, using my 
GitHub project: https://github.com/hpaluch-pil/grpc-build-scripts

To cross-build gRPC for aarch64 do this:
```shell
sudo apt-get install git-core # Debian/Ubuntu
sudo dnf     install git-core # Fedora
sudo zypper  in      git-core # openSUSE LEAP

mkdir -p ~/projects
cd ~/projects
git clone https://github.com/hpaluch-pil/grpc-build-scripts.git
cd grpc-build-scripts

# on Debian and/or Ubuntu:
common/01-install-apt.sh
# on Fedora:
common/01-install-dnf.sh
# on openSUSE LEAP:
common/01-install-zypper.sh

# continued - common:
# line below will checkout gRPC sources into ~/src/grpc
common/02-clone-source.sh
# warning: it purges existing gRPC installation in /opt/grpc-VERSION!
common/03-prepare-install-basedir.sh

cross-aarch64/05-install-gcc11-aarch64.sh
cross-aarch64/10-build-host.sh
cross-aarch64/20-build-aarch64.sh
cross-aarch64/30-example-aarch64.sh
```

Finally run script `./cross-build-aarch64.sh` in this folder to 
cross-build this example for aarch64. Binaries
will be under `cmake/build-aarch64-none-linux-gnu/` folder.

### Setup with CMake: Windows

> WARNING!
> Debug builds are broken: while gRPC builds happily in Debug mode the `grpc++_reflection` always
> builds in Release mode. It causes fatal build error when linking it to this project...
> Error looks like: `LNK2038 mismatch detected for '_ITERATOR_DEBUG_LEVEL': value '2' doesn't match value '0' in greeter_client.obj`
> I found no way how to fix it and official Issue is not helpful: https://github.com/grpc/grpc/issues/23326

You need to install:
* CMake, tested version: 3.20.2
* Visual Studio 2019 with `C++ Desktop Workload`
* Git for Windows, tested versino 2.53 (but DO NOT USE version 2.54! - it crashes while checking out gRPC,
  see https://github.com/git-for-windows/git/issues/6210)

First in Git Bash build and install gRPC:
```shell
mkdir -p /c/src
cd /c/src
git clone --recurse-submodules -b v1.74.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
```

Now in This project run in CMD:
```cmd
REM copy build_grpc.cmd from this folder to c:\src and:
md c:\TEMP
cd /d "c:\src"
build_grpc.cmd c:\TEMP
```

Finally in this project run in CMD:
```cmd
rebuild_windows.cmd
```

On success, target binaries are in `c:\TEMP\build\grpc-hello\Release`.


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

- to build it with Bazel tool:
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

Most of the grpc(++) detection code (cmake build) is from this package:
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

