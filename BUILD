load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")

# Runs on "standard" execution platform determined by --platforms
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
        # NB: this rule creates non-test actions such as
        # TemplateExpand: Expanding template test_on_chainguard_executor-test.sh
        # This would also be the case for compilation/linking actions in a cc_test for example.
        # The "test." prefix ensures we only target the "test" execution group.
        "test.container-image": "docker://cgr.dev/chainguard/python",
    }
)
