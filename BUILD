load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")

# Run on execution platform determined by --platforms
diff_test(
    name = "test",
    file1 = "MODULE.bazel",
    file2 = "BUILD.bazel",
)

# Should merge the exec_properties
diff_test(
    name = "test_on_chainguard_executor",
    file1 = "MODULE.bazel",
    file2 = "BUILD.bazel",
    exec_properties = {
        "container-image": "cgr.dev/chainguard/python",
    }
)
