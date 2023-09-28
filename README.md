# Useful

LibUseful is a toy library to showcase various build automation features of CMake, CTest and CPack.

## Building

The build definition aims at showcasing as many good practices as reasonably possible. The author knows that the set of
best practices is an ever-moving target and the scripts are most certainly even in their current incarnation leave room
for improvement.

### Presets

Container technologies serve developers well in defining an environment that is known to work when building some
software. The series of commands however that build, install, package as software are often captured as CI scripts,
often wrapped into YAML. To help replay the exact same commands for local testing/development, they may ship as shell
scripts with CI becoming a oneliner. However, this doesn't help developers much diagnose failures with debuggers,
tracers, profilers in their IDE of choice.

Every IDE has come up with some configuration file for devs to communicate to the IDE how they want CMake to be invoked
on their behalf. These configuration files however don't transfer between dev team members using a different IDE or
even to CI scripts.

CMake presets is Kitware's take (having consulted with IDE vendors) on a common, extensible configuration file which
captures the usual:

| Step         | Command-line fragment                                      |
|--------------|------------------------------------------------------------|
| Configure    | `cmake -G <generator> -S <path> -B <path> ...`             |
| Build        | `cmake --build <path> --target <name> --config <name> ...` |
| Test         | `ctest --test-dir <path> --build-config <name> ...`        |
| Install      | `cmake --install <path> --prefix <path> --config <name>`   |
| Package      | `cpack -G <generator> --config <path>`                     |

workflow of dealing with CMake projects. When codifying the invocations as presets, these steps become:

| Step         | Command-line fragment                  |
|--------------|----------------------------------------|
| Configure    | `cmake --preset <name>`                |
| Build        | `cmake --build <path> --preset <name>` |
| Test         | `ctest --preset <name>`                |
| _Install_    | `cmake --build <path> --preset <name>` |
| Package      | `cpack --preset <name>`                |

To allow invoking the entire process as a oneliner, CMake presets allows assembling this workflow.

| Step         | Command-line fragment     |
|--------------|---------------------------|
| Workflow     | `cmake --workflow <name>` |

This way CI and developers using any IDE can invoke the entire process as a one-liner or invoke individual steps from
any command-line or using integrations provided by IDEs. For more on presets, refer to the
[relevant docs](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html).

#### CI/CD versus development

Should users have an environment which differs from that of CI, or they simply want to develop using consciously chosen
differing CMake invocations (lacking resources to build all GPU device targets regularly in their dev loop, using
out-of-band compilers which don't build cleanly with
[`COMPILE_WARNING_AS_ERROR`](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_WARNING_AS_ERROR.html), etc.), they
can define their own presets. CMake will look for a `CMakePresets.json` file in the project root, which is owned by the
project, should be commited to version control and should reflect invocations used in CI/CD known to work in
environments used in CI/CD, and it will be merged with another file next to it `CMakeUserPrests.json`. This latter
should regularly be ignored by version control. It also implicitly includes the project's presets, so if only a few
deltas are needed, the majority of the JSON need not be copied over.

In that spirit, projects should:

- not include files in `CMakePresets.json` which are absent from the repo itself.
- try to define your presets using multiple groups of orthogonal settings (`hidden: true`) presets which the user can
  individually override without having to rehash all the commonality they agree with.

**Shortcomings**

CMake presets currently have a few shortcomings:

- It lacks dedicated install presets. This is only a minor nuisance, as it can nearly fully be emulated using a build
  preset invoking the `install` target. The only feature lost is the ability to install multiple configurations to
  possibly multiple prefixes from a single configuration.
  [Kitware issue](https://gitlab.kitware.com/cmake/cmake/-/issues/24875)
- Currently there's no way to mitigate the combinatorial explosion of entries depending on the number of supported
  configurations, builds, tests, etc. The size of the presets JSON grows rapidly when wanting to support multiple
  platforms, configurations that manifest as necessarily different CMake invocations.
  [Kitware issue](https://gitlab.kitware.com/cmake/cmake/-/issues/22538)
- MSVC on Windows traditionally (with Clang following suit) require some environment variables be set in order to
  function properly (find their own STL, libs, etc.). These variables are set by shell scripts / PowerShell modules,
  with results being referred to as developer command-prompts / shells. Presets do capture the ability to set env vars
  which the build or tests may require, however Kitware seems unresponsive in wanting to tie the knot in capturing env
  requirements of toolchains using Makefile generators.
  [Kitware issue](https://gitlab.kitware.com/cmake/cmake/-/issues/21619) In all honesty, not that they should.
  Toolchain vendors could expose their toolchains in preset-friendly ways to CMake too. Somewhat related
  [CMake Tools issue](https://github.com/microsoft/vscode-cmake-tools/issues/2912)
