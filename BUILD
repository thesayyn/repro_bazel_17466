load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load(":test_on.bzl", "test_on")

# Should merge the exec_properties
test_on(
    name = "test_on_chainguard_executor",
    rule = diff_test,
    file1 = "a.txt",
    file2 = "b.txt",
    exec_properties = {
        # NB: this rule creates non-test actions such as
        # TemplateExpand: Expanding template test_on_chainguard_executor-test.sh
        # This would also be the case for compilation/linking actions in a cc_test for example.
        # The "test." prefix ensures we only target the "test" execution group.
        "test.container-image": "docker://cgr.dev/chainguard/python",
    }
)
