workspace(name = "grpc_hello_cpp")

# FROM: https://github.com/stackb/rules_proto
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_stack_rules_proto",

    # Branch: master
    # Commit: 7c95feba87ae269d09690fcebb18c77d8b8bcf6a
    # Date: 2021-11-16 02:17:58 +0000 UTC
    # URL: https://github.com/stackb/rules_proto/commit/7c95feba87ae269d09690fcebb18c77d8b8bcf6a
    # V2 (#193)
    #sha256 = "1190c296a9f931343f70e58e5f6f9ee2331709be4e17001bb570e41237a6c497",
    #strip_prefix = "rules_proto-7c95feba87ae269d09690fcebb18c77d8b8bcf6a",
    #urls = ["https://github.com/stackb/rules_proto/archive/7c95feba87ae269d09690fcebb18c77d8b8bcf6a.tar.gz"],

    # latest master as of 2022-04-23
    sha256 = "733bdc9267a90404d48668853025bb6c660d7a23e38f819335b03865fe2bee89",
    strip_prefix = "rules_proto-36ceb79a987a6de33768c8bdb08d22b516a7e32e",
    urls = ["https://github.com/stackb/rules_proto/archive/36ceb79a987a6de33768c8bdb08d22b516a7e32e.tar.gz"],

    # from: https://github.com/bazelbuild/rules_k8s/blob/master/WORKSPACE
    #sha256 = "2c62ecc133ee0400d969750a5591909a9b3839af402f9c9d148cffb0ce9b374b",
    #strip_prefix = "rules_proto-6b334ece48828fb8e45052976d3516f808819ac7",
    #urls = ["https://github.com/stackb/rules_proto/archive/6b334ece48828fb8e45052976d3516f808819ac7.tar.gz"],

)

register_toolchains("@build_stack_rules_proto//toolchain:standard")
#register_toolchains("@build_stack_rules_proto//toolchain:prebuilt")

load("@build_stack_rules_proto//deps:core_deps.bzl", "core_deps")

core_deps()

load("@build_stack_rules_proto//deps:protobuf_core_deps.bzl", "protobuf_core_deps")

protobuf_core_deps()

load("@build_stack_rules_proto//deps:prebuilt_protoc_deps.bzl", "prebuilt_protoc_deps")

prebuilt_protoc_deps()

load("@build_stack_rules_proto//deps:grpc_core_deps.bzl", "grpc_core_deps")

grpc_core_deps()

# ----------------------------------------------------
# Core gRPC
# ----------------------------------------------------

load(
    "@com_github_grpc_grpc//bazel:grpc_deps.bzl",
    "grpc_deps",
)

# Monkey patch to use more recent BoringSSL (normally declared by grpc_deps() below
# to fix compile errors under GCC 11 which no longer permits
# array bounds mismatches (for good).
# BEWARE: Only commits from branch 'master-with-bazel'
#         are usable for us (other branches of BoringSSL have no Bazel files)!
http_archive(
  name = "boringssl",
  # this crashes, because it requires C++14 (not enabled by default)
  #urls = [ "https://github.com/google/boringssl/archive/7b5527cd39f884b6d1b1178cce2cb6258bc059a4.tar.gz"],
  #sha256 = "05c2ba5084e6769287c2934784724d4d710d92e90823d122246b2430dd68141e",
  #strip_prefix = "boringssl-7b5527cd39f884b6d1b1178cce2cb6258bc059a4",

  # this crashes with SHA224 mismatch error
  #urls = [ "https://github.com/google/boringssl/archive/d0583f510ac4f2f96f423efd31a01d08b6791191.tar.gz"],
  #sha256 = "fa5a8a9b9991e2d94e904f7f6bb5b94815c4b8cb46bbad1e32dba46218147a6d",
  #strip_prefix = "boringssl-d0583f510ac4f2f96f423efd31a01d08b6791191",

  # and finally this commit fixes both BoringSSL array boundary errors
  urls = [ "https://github.com/google/boringssl/archive/3f0466c7c0ae341e214414989cd92b47d7a59db7.tar.gz"],
  sha256 = "9c7dd8d2f49d7da006299fc2f19ad55d59c303a14b7c73b3ff6d8a44f061728d",
  strip_prefix = "boringssl-3f0466c7c0ae341e214414989cd92b47d7a59db7",

)

grpc_deps()

