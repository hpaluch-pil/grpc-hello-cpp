package(default_visibility = ["//visibility:public"])

load("@rules_proto//proto:defs.bzl", "proto_library")
load("@build_stack_rules_proto//rules/cc:grpc_cc_library.bzl", "grpc_cc_library")
load("@build_stack_rules_proto//rules/cc:proto_cc_library.bzl", "proto_cc_library")
load("@build_stack_rules_proto//rules:proto_compile.bzl", "proto_compile")

proto_library(
    name = "hello_proto",
    srcs = ["protos/helloworld.proto"],
    visibility = ["//visibility:public"],
)

proto_compile(
    name = "hello_cpp_compile",
    outputs = [
        "helloworld.grpc.pb.cc",
        "helloworld.grpc.pb.h",
        "helloworld.pb.cc",
        "helloworld.pb.h",
    ],
    plugins = [
        "@build_stack_rules_proto//plugin/builtin:cpp",
        "@build_stack_rules_proto//plugin/grpc/grpc:protoc-gen-grpc-cpp",
    ],
    proto = "hello_proto",
)

proto_cc_library(
    name = "~ello_cc_library",
    srcs = ["hello.pb.cc"],
    hdrs = ["hello.pb.h"],
    visibility = ["//visibility:public"],
    deps = ["@com_google_protobuf//:protobuf"],
)

grpc_cc_library(
    name = "hello_grpc_cc_library",
    srcs = ["hello.grpc.pb.cc"],
    hdrs = ["hello.grpc.pb.h"],
    visibility = ["//visibility:public"],
    deps = [
        ":hello_cc_library",
        "@com_github_grpc_grpc//:grpc++",
        "@com_github_grpc_grpc//:grpc++_reflection",
    ],
)

cc_binary(
    name = "greeter_client",
    srcs = ["greeter_client.cc"],
    deps = [":hello_grpc_cc_library"],
)

cc_binary(
    name = "greeter_server",
    srcs = ["greeter_server.cc"],
    deps = [":hello_grpc_cc_library"],
)

