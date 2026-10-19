# Modified version by Henryk Paluch
# based on:
# Copyright 2018 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# cmake build file for C++ helloworld example.
# Assumes protobuf and gRPC have been installed using cmake.
# See cmake_externalproject/CMakeLists.txt for all-in-one cmake build
# that automatically builds all the dependencies before building helloworld.

cmake_minimum_required(VERSION 3.5.1)

project(HelloWorld C CXX)

# see: https://www.alcf.anl.gov/sites/default/files/2020-07/ANL%202020%20CMake%20%26%26%20Friends%20Part1_0.pdf
set(default_build_type "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  # IMPORTANT: This applies only for Makefile and Ninja generators
  # Visual Studio includes all build types in single generated Solution!
  message(STATUS
  "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
      STRING "Choose the type of build." FORCE)
  # Set the possible values for build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

set (CMAKE_CXX_STANDARD 17)

# available in system as:
# /usr/share/cmake/Modules/FindThreads.cmake
# openSUSE package:  cmake-full
find_package(Threads REQUIRED)

# Protobuf cmake package is directly provided by cmake:
# /usr/share/cmake/Modules/FindProtobuf.cmake
# openSUSE package:  cmake-full
if(UNIX AND NOT CMAKE_CROSSCOMPILING)
  find_package(Protobuf REQUIRED)
else()
  option(protobuf_MODULE_COMPATIBLE TRUE)
  find_package(Protobuf CONFIG REQUIRED)
endif()
message(STATUS "Using protobuf ${Protobuf_VERSION}")
set(_PROTOBUF_LIBPROTOBUF protobuf::libprotobuf)

if(CMAKE_CROSSCOMPILING)
  find_program(_PROTOBUF_PROTOC protoc)
else()
  set(_PROTOBUF_PROTOC $<TARGET_FILE:protobuf::protoc>)
endif()

if(UNIX)
  if(CMAKE_CROSSCOMPILING)
    find_package(gRPC CONFIG REQUIRED)
  else()
    # OpenSUSE has no cmake package for GRPC
    # thus we must fallback to pkg-config (will be not portable to Windows...)
    find_package(PkgConfig REQUIRED)
    pkg_search_module(GRPC REQUIRED grpc)
  endif()
  message(STATUS "found grpc ${GRPC_VERSION}, libraries: '${GRPC_LIBRARIES}'")

  #pkg_search_module(GRPCPP REQUIRED grpc++)
  #message(STATUS "found grpc++ ${GRPCPP_VERSION}, libraries: '${GRPCPP_LIBRARIES}'")
  #set(_GRPC_GRPCPP "${GRPCPP_LIBRARIES}")
else()
  set(GRPC_INSTALL_DIR "c:/libs/grpc")
  # on Windows use CMake package
  # Looks for gRPCConfig.cmake file installed by gRPC's cmake installation.
  find_package(gRPC CONFIG REQUIRED)
  message(STATUS "Using gRPC ${gRPC_VERSION}")
endif()

set(_GRPC_GRPCPP gRPC::grpc++ )
set(_REFLECTION gRPC::grpc++_reflection)
if(CMAKE_CROSSCOMPILING)
  find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
else()
  set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
endif()

# Proto file
get_filename_component(hw_proto "helloworld.proto" ABSOLUTE)
get_filename_component(hw_proto_path "${hw_proto}" PATH)

# Generated sources
set(hw_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.cc")
set(hw_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.h")
set(hw_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.cc")
set(hw_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.h")
add_custom_command(
      OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}" "${hw_grpc_srcs}" "${hw_grpc_hdrs}"
      COMMAND ${_PROTOBUF_PROTOC}
      ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
        --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
        -I "${hw_proto_path}"
        --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${hw_proto}"
      DEPENDS "${hw_proto}")

# Include generated *.pb.h files
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

# hw_grpc_proto
add_library(hw_grpc_proto
  ${hw_grpc_srcs}
  ${hw_grpc_hdrs}
  ${hw_proto_srcs}
  ${hw_proto_hdrs})
target_link_libraries(hw_grpc_proto
  ${_REFLECTION}
  ${_GRPC_GRPCPP}
  ${_PROTOBUF_LIBPROTOBUF})

# Targets greeter_[async_](client|server)
foreach(_target
  greeter_client greeter_server)
  add_executable(${_target} "${_target}.cc")
  if(UNIX)
    # we use -DLINUX for any other system than Windows
    target_compile_definitions(${_target} PUBLIC LINUX)
  else()
    target_link_directories(${_target} PUBLIC "${GRPC_INSTALL_DIR}/lib")
  endif()
  target_link_libraries(${_target}
    hw_grpc_proto
    ${_REFLECTION}
    ${_GRPC_GRPCPP}
    ${_PROTOBUF_LIBPROTOBUF})
endforeach()
