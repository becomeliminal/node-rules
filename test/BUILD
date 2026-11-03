subinclude("//build_defs:node")

build_rule(
    name = "hermetic_test",
    srcs = ["hermetic_test.sh"],
    data = ["//third_party/node:node"],
    outs = ["hermetic_test"],
    cmd = "cp $SRCS $OUT",
    binary = True,
    test = True,
    no_test_output = True,
    test_cmd = "$TEST third_party/node/node v22.23.2",
)

build_rule(
    name = "native_tools_test",
    srcs = ["native_tools_test.sh"],
    data = ["//third_party/bun:bun", "//third_party/oxlint:oxlint"],
    outs = ["native_tools_test"],
    cmd = "cp $SRCS $OUT",
    binary = True,
    test = True,
    no_test_output = True,
    test_cmd = "$TEST third_party/bun/bun 1.4.4 third_party/oxlint/oxlint 1.91.0",
)
