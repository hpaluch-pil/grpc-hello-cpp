/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <iostream>
#include <memory>
#include <string>

#ifdef LINUX
#include <time.h>
#else
#define WIN32_LEAN_AND_MEAN // gRPC will completely choke with full headers...
#define NOMINMAX // avoid min()/max() collision with std:: templates
#include <windows.h>
#endif

#include <grpcpp/grpcpp.h>

#ifdef BAZEL_BUILD
#include "examples/protos/helloworld.grpc.pb.h"
#else
#include "helloworld.grpc.pb.h"
#endif

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;
using helloworld::Greeter;
using helloworld::HelloReply;
using helloworld::HelloRequest;

class GreeterClient {
 public:
  Status status; // allow caller to see all gory details when things fail
  GreeterClient(std::shared_ptr<Channel> channel)
      : stub_(Greeter::NewStub(channel)), status() {}

  // Assembles the client's payload, sends it and presents the response back
  // from the server.
  std::string SayHello(const std::string& user) {
    // Data we are sending to the server.
    HelloRequest request;
    request.set_name(user);

    // Container for the data we expect from the server.
    HelloReply reply;

    // Context for the client. It could be used to convey extra information to
    // the server and/or tweak certain RPC behaviors.
    ClientContext context;

    // The actual RPC.
    status = stub_->SayHello(&context, request, &reply);

    // Act upon its status.
    if (status.ok()) {
      return reply.message();
    } else {
      return "RPC failed"; // error now handled by caller
    }
  }

 private:
  std::unique_ptr<Greeter::Stub> stub_;
};

static const char *DEFAULT_TARGET = "localhost:50051";

static int usage(char **argv)
{
	using namespace std;

	cerr << "Usage: " << argv[0] << " [ --target=" << DEFAULT_TARGET << " ]" << endl;
	return EXIT_FAILURE;
}

int main(int argc, char** argv) {
#ifdef LINUX
  struct timespec startTime, endTime;
#else
    LARGE_INTEGER timerFreq, startTime, endTime;
    QueryPerformanceFrequency(&timerFreq); // FIXME: error handling
#endif
  // Instantiate the client. It requires a channel, out of which the actual RPCs
  // are created. This channel models a connection to an endpoint specified by
  // the argument "--target=" which is the only expected argument.
  // We indicate that the channel isn't authenticated (use of
  // InsecureChannelCredentials()).
  std::string target_str(DEFAULT_TARGET);
  std::string arg_str("--target");
  if (argc > 1) {
    std::string arg_val = argv[1];
    size_t start_pos = arg_val.find(arg_str);
    if (start_pos != std::string::npos) {
      start_pos += arg_str.size();
      if (arg_val[start_pos] == '=') {
        target_str = arg_val.substr(start_pos + 1);
      } else {
        std::cerr << "The only correct argument syntax is --target="
                  << std::endl;
        return usage(argv);
      }
    } else {
      std::cerr << "The only acceptable argument is --target=" << std::endl;
      return usage(argv);
    }
  }
  std::cout << "Connecting to " << target_str << " ..." << std::endl;
  GreeterClient greeter(
      grpc::CreateChannel(target_str, grpc::InsecureChannelCredentials()));
  // WARNING! When we are here we are not connected YET (failure will happen just at greeter.SayHello(...) later!
  std::string user("world");
#ifdef LINUX
  clock_gettime(CLOCK_MONOTONIC,&startTime);
#else
  QueryPerformanceCounter(&startTime);  // FIXME: error handling
#endif
  std::string reply = greeter.SayHello(user);
  if (!greeter.status.ok()){
      std::cerr << "ERROR: RPC call failed with " << greeter.status.error_code()
    		    << ": " << greeter.status.error_message() << std::endl;
      return EXIT_FAILURE;
  }
#ifdef LINUX
  clock_gettime(CLOCK_MONOTONIC,&endTime);
  uint64_t time_us = (((endTime.tv_sec * 1000000000ULL + endTime.tv_nsec)
                    -(startTime.tv_sec * 1000000000ULL + startTime.tv_nsec))/1000ULL);
#else
  QueryPerformanceCounter(&endTime);  // FIXME: error handling
  uint64_t time_us = ((endTime.QuadPart - startTime.QuadPart) * 1000000ULL / timerFreq.QuadPart);
#endif
  std::cout << "Greeter received: " << reply << std::endl;
  std::cout << "gRPC call took: " << time_us << " [us]" << std::endl;

  return EXIT_SUCCESS;
}
