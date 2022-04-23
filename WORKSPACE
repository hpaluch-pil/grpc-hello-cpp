workspace(name = "grpc_hello_cpp")

# FROM: https://github.com/stackb/rules_proto
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Branch: master
# Commit: 7c95feba87ae269d09690fcebb18c77d8b8bcf6a
# Date: 2021-11-16 02:17:58 +0000 UTC
# URL: https://github.com/stackb/rules_proto/commit/7c95feba87ae269d09690fcebb18c77d8b8bcf6a
#
# V2 (#193)
# Size: 885598 (886 kB)
http_archive(
    name = "build_stack_rules_proto",
    #sha256 = "1190c296a9f931343f70e58e5f6f9ee2331709be4e17001bb570e41237a6c497",
    #strip_prefix = "rules_proto-7c95feba87ae269d09690fcebb18c77d8b8bcf6a",
    #urls = ["https://github.com/stackb/rules_proto/archive/7c95feba87ae269d09690fcebb18c77d8b8bcf6a.tar.gz"],

    # latest master as of 2022-04-11
    sha256 = "733bdc9267a90404d48668853025bb6c660d7a23e38f819335b03865fe2bee89",
    strip_prefix = "rules_proto-36ceb79a987a6de33768c8bdb08d22b516a7e32e",
    urls = ["https://github.com/stackb/rules_proto/archive/36ceb79a987a6de33768c8bdb08d22b516a7e32e.tar.gz"],

    # from: https://github.com/bazelbuild/rules_k8s/blob/master/WORKSPACE
    #sha256 = "2c62ecc133ee0400d969750a5591909a9b3839af402f9c9d148cffb0ce9b374b",
    #strip_prefix = "rules_proto-6b334ece48828fb8e45052976d3516f808819ac7",
    #urls = ["https://github.com/stackb/rules_proto/archive/6b334ece48828fb8e45052976d3516f808819ac7.tar.gz"],

)


load("@build_stack_rules_proto//deps:core_deps.bzl", "core_deps")
core_deps()

load("@build_stack_rules_proto//deps:grpc_core_deps.bzl", "grpc_core_deps")
grpc_core_deps()

load("@build_stack_rules_proto//deps:grpc_deps.bzl", "grpc_deps")
grpc_deps()

# To fix: https://github.com/grpc/grpc/issues/22436
load("@com_github_grpc_grpc//bazel:grpc_extra_deps.bzl", "grpc_extra_deps")
grpc_extra_deps()


#register_toolchains("@build_stack_rules_proto//toolchain:standard")
register_toolchains("@build_stack_rules_proto//toolchain:prebuilt")
