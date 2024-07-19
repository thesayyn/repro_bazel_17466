# Reproduction for merging per-target exec properties for the test exec group

The `--use_target_platform_for_tests` flag landed in https://github.com/bazelbuild/bazel/pull/17390.
However the final comment is "Not until we address the issue with merging per-target exec properties for the `test` exec group.
The follow-up issue https://github.com/bazelbuild/bazel/issues/17466 requests a reproduction, which follows.

1. `.bazelrc` sets `--use_target_platform_for_tests`.

2. In `BUILD` we have a test that requests execution properties. Without loss of generality, we choose a different executor image:

```
exec_properties = {
    "container-image": "cgr.dev/chainguard/python",
}
```

3. However when we query the actions produced, we see `ExecutionInfo: {container-image: docker://public.ecr.aws/docker/library...}` so this test will execute on the wrong image.

```
% bazel aquery :all

...

action 'Testing //:test_on_chainguard_executor'
  Mnemonic: TestRunner
  Target: //:test_on_chainguard_executor
  Configuration: darwin_arm64-fastbuild
  Execution platform: @aspect_bazel_lib//platforms:x86_64_linux_remote
# Configuration: d290d88ddc649b7ef54bfd29373a15acc313ceb1365ba5d75db4430d50a0db70
# Execution platform: @@aspect_bazel_lib~//platforms:x86_64_linux_remote
  ExecutionInfo: {OSFamily: Linux, container-image: docker://public.ecr.aws/docker/library/python@sha256:247105bbbe7f7afc7c12ac893be65b5a32951c1d0276392dc2bf09861ba288a6}
```

4. If we turn the flag off, we observe the correct execution info appears, but of course on the wrong platform:

```
% bazel aquery :all --nouse_target_platform_for_tests

...

action 'Testing //:test_on_chainguard_executor'
  Mnemonic: TestRunner
  Target: //:test_on_chainguard_executor
  Configuration: darwin_arm64-fastbuild
  Execution platform: @platforms//host:host
# Configuration: 22d69305ba7dc7e805ed925478bcfc23f2ff661758e5174ee789c344ebba5957
# Execution platform: @@platforms//host:host
  ExecutionInfo: {container-image: docker://cgr.dev/chainguard/python}
```

Desired is for the aquery to merge the properties - it should look like

```
action 'Testing //:test_on_chainguard_executor'
  Mnemonic: TestRunner
  Target: //:test_on_chainguard_executor
  Configuration: darwin_arm64-fastbuild
# Execution platform: @@aspect_bazel_lib~//platforms:x86_64_linux_remote
  ExecutionInfo: {OSFamily: Linux, container-image: docker://cgr.dev/chainguard/python}
```