workspace(name = "grpc_hello_cpp")

# Trying pre V2 version from:
# https://github.com/stackb/rules_proto/tree/b2913e6340bcbffb46793045ecac928dcf1b34a5

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_stack_rules_proto",
    urls = ["https://github.com/stackb/rules_proto/archive/b2913e6340bcbffb46793045ecac928dcf1b34a5.tar.gz"],
    sha256 = "d456a22a6a8d577499440e8408fc64396486291b570963f7b157f775be11823e",
    strip_prefix = "rules_proto-b2913e6340bcbffb46793045ecac928dcf1b34a5",
)

load("@build_stack_rules_proto//cpp:deps.bzl", "cpp_grpc_compile")
cpp_grpc_compile()
      
load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")
grpc_deps()

