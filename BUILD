#package(default_visibility = ["//visibility:public"])

load("@build_stack_rules_proto//cpp:cpp_grpc_library.bzl", "cpp_grpc_library")

proto_library(
    name = "helloworld_proto",
    srcs = [
        "protos/helloworld.proto",
    ],
    visibility = [
        "//visibility:public",
    ],
)

cpp_grpc_library(
    name = "greeter_stub",
    deps = [":helloworld_proto"],
)

cc_binary(
    name = "greeter_client",
    srcs = ["greeter_client.cc"],
    deps = [":greeter_stub"],
)


