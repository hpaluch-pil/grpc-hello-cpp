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
#include <sstream>
#include <memory>
#include <string>
// I'm old-fashioned C-String boy :-O
#include <stdlib.h> // atoi(3)
#include <string.h> // strncmp(3)

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

class MyStats {
protected:
  double fMin, fMax, fSum;
  int iCount; // number of items
public:
  MyStats(): fMin(0.0), fMax(0.0), fSum(0.0),iCount(0){};
  int AddItem(double fValue){
    if (iCount==0){
      fMin = fMax = fValue;
    } else {
      if (fMin > fValue)
        fMin = fValue;
      if (fMax < fValue)
        fMax = fValue;
    }
    fSum += fValue;
    return ++iCount;
  }
  int getCount(){ return iCount; }
  std::string ToString(){
    std::stringstream ss;
    if (iCount <=0 ){
      ss << "ERROR: No Data";
    } else {
      ss << "Min: " << fMin << " Avg: " << (fSum/iCount) << " Max: " << fMax << " Count: " << iCount << std::endl;
    }
    return ss.str();
  }
};

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

static const int DEFAULT_REPEAT = 1;
static const char *DEFAULT_TARGET = "localhost:50051";

static int usage(char **argv)
{
	using namespace std;

	cerr << "Usage: " << argv[0] << " [ --target=" << DEFAULT_TARGET << " ] [ --repeat=" << DEFAULT_REPEAT << " ]" << endl;
	return EXIT_FAILURE;
}

int main(int argc, char** argv) {
  static const char *ARG_TARGET = "--target=";
  static const char *ARG_REPEAT = "--repeat=";
  int i=0;
  int iRepeat = DEFAULT_REPEAT;
  MyStats rpcStats;
#ifdef LINUX
  struct timespec startTime, endTime;
#else
    LARGE_INTEGER timerFreq, startTime, endTime;
    QueryPerformanceFrequency(&timerFreq); // FIXME: error handling
#endif
  // We indicate that the channel isn't authenticated (use of
  // InsecureChannelCredentials()).
  std::string target_str(DEFAULT_TARGET);

  for(i=1;i<argc;i++){
    if(strncmp(argv[i],ARG_TARGET,strlen(ARG_TARGET))==0){
      target_str=  argv[i]+strlen(ARG_TARGET);
    } else if (strncmp(argv[i],ARG_REPEAT,strlen(ARG_REPEAT))==0){
      char *repeat_str = argv[i]+strlen(ARG_REPEAT);
      iRepeat = atoi(repeat_str);
      if (iRepeat <= 0){
        std::cerr << "ERROR: invalid repeat number: '" << argv[i] << "' converted to: " << iRepeat << std::endl;
        return usage(argv);
      }
    } else {
      std::cerr << "ERROR: Unknown argument: '" << argv[i] << "'" << std::endl;
      return usage(argv);
    }
  }

#ifdef _MSC_VER
  std::cout << "Build with MSVC: " << _MSC_VER/100.0 << std::endl;
#endif
#ifdef __VERSION__
  std::cout << "Build with: " << __VERSION__ << std::endl;
#endif
  std::cout << "Using gRPC Version: " << grpc::Version() << std::endl;
  std::cout << "Connecting to " << target_str << " ..." << std::endl;
  GreeterClient greeter(
      grpc::CreateChannel(target_str, grpc::InsecureChannelCredentials()));
  // WARNING! When we are here we are not connected YET (failure will happen just at greeter.SayHello(...) later!
  std::string user("world");
  for(i=0;i<iRepeat;i++){
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
    std::cout << "gRPC call #" << (i+1) << " took: " << (time_us/1000.0) << " [ms]" << std::endl;
    rpcStats.AddItem(time_us / 1000.0);
  }
  if (rpcStats.getCount()>1){
    std::cout << "gRPC call statistics [ms]: " << rpcStats.ToString() << std::endl;
  }
  return EXIT_SUCCESS;
}
