def _exec_on_transition_impl(settings, attr):
    return {
        # "//command_line_option:platforms": str(attr.platform),
        "//command_line_option:platforms": settings["//command_line_option:platforms"],
        "//command_line_option:extra_execution_platforms": str(attr.platform),
        "//command_line_option:use_target_platform_for_tests": "false",
    }

_exec_on_transition = transition(
    implementation = _exec_on_transition_impl,
    inputs = ["//command_line_option:platforms"],
    outputs = [
        "//command_line_option:platforms",
        "//command_line_option:extra_execution_platforms",
        "//command_line_option:use_target_platform_for_tests",
    ],
)


def _exec_on_test_impl(ctx):
    result = []

    # ctx.attr.binary is a singleton list if this rule uses an outgoing transition.
    if type(ctx.attr.binary) == type([]):
        binary = ctx.attr.binary[0]
    else:
        binary = ctx.attr.binary

    default_info = binary[DefaultInfo]
    files = default_info.files
    new_executable = None
    original_executable = default_info.files_to_run.executable
    runfiles = default_info.default_runfiles

    if not original_executable:
        fail("Cannot transition a 'binary' that is not executable")

    new_executable_name = ctx.attr.basename if ctx.attr.basename else original_executable.basename

    # In order for the symlink to have the same basename as the original
    # executable (important in the case of proto plugins), put it in a
    # subdirectory named after the label to prevent collisions.
    new_executable = ctx.actions.declare_file(ctx.label.name + "/" + new_executable_name)
    ctx.actions.symlink(
        output = new_executable,
        target_file = original_executable,
        is_executable = True,
    )
    files = depset(direct = [new_executable], transitive = [files])
    runfiles = runfiles.merge(ctx.runfiles([new_executable]))
  
    result.append(
        DefaultInfo(
            files = files,
            runfiles = runfiles,
            executable = new_executable,
        ),
    )

    if RunEnvironmentInfo in binary:
        result.append(binary[RunEnvironmentInfo])

    return result

exec_on_test= rule(
    implementation = _exec_on_test_impl,
    attrs = {
        "basename": attr.string(),
        "binary": attr.label(allow_files = True, cfg = config.exec("test")),
    },
    exec_groups = {
        "test": exec_group(
            toolchains = ["//tools/test:default_test_toolchain_type"],
        ),
    },
    test = True,
)

def test_on(name, rule, **kwargs):
    """
    A test that runs on a specific execution platform.

    Args:
        name: The name of the test.
        rule: The rule to run the test on.
        **kwargs: Additional arguments to pass to the test.

    Returns:
        A test that runs on a specific execution platform.
    """
    tags = kwargs.pop("tags", [])
    visibility = kwargs.pop("visibility", [])
    testonly = kwargs.pop("testonly", None)


    rule(
        name = name + "_target",
        tags = tags + ["manual"],
        visibility = visibility,
        testonly = testonly,
        **kwargs
    )
    exec_on_test(
        name = name,
        binary = ":" + name + "_target",
        tags = tags,
        visibility = visibility,
        testonly = testonly,
    )


