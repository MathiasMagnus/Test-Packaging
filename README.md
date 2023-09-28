# Useful

LibUseful is a toy library to showcase various build automation features of CMake, CTest and CPack.

## Building

The build definition aims at showcasing as many good practices as reasonably possible. The author knows that the set of
best practices is an ever-moving target and the scripts are most certainly even in their current incarnation leave room
for improvement.

### Build definition

CMake is a scripting language and writing maintainable, easy to understand build definitions is as much dependent on
scripting style as in any other sciprt language. Here are a couple of best practices to keep in mind.

#### KISS

It is tempting to automate more than strictly necessary, but resist that temptation. CMake scripts should do no more
than build-test-install-package.

Convenience features, especially "smart" conveniences will often bite users or simply become a hassle to maintain.

- Conveniences around turning on "warnings as errors" behavior in compilers have become prevalent in the ecosystem.
  Just one
  [example](https://github.com/KhronosGroup/SPIRV-Tools/blob/e553b884c7c9febaa4e52334f683641fb5f196a0/CMakeLists.txt#L111-L144)
  on how messy these facilities can get. These practices give rise to built-in functinality around controlling
  different aspects of build (
  [`COMPILE_WARNING_AS_ERROR`](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_WARNING_AS_ERROR.html) or
  [`MSVC_RUNTIME_LIBRARY`](https://cmake.org/cmake/help/latest/prop_tgt/MSVC_RUNTIME_LIBRARY.html)
  ), previously requiring manual meddling with compiler flags. If such a feature is missing from CMake, carefully
  consider the cost/gain benefit of introducing a project-specific machinery.
- Conveniences around dependency management, see later.

#### Dependency management

Conveniences around obtaining dependencies on behalf of the user _almost always_ gets in the way of some use case,
but primarily in the way of advanced users. (The author) having cooked many such conveniences for AMD, Khronos and
teaching material to novices and has done maintaining a lot of these: "it's not worth it". The only robust solution
in CMake (currently) is `find_package(<name> REQUIRED)` and expecting said dependency to be found somehow and be a
pre-built install tree of said dependency. Everything else will break.

Accept C/C++/HIP/CUDA/etc projects having to use a package manager of sorts for the least painful experience for devs
and users alike. Make sure your dependencies are available in popular package managers. (The author is an advocate of
[Vcpkg](https://vcpkg.io), but anything is better than nothing.)

Git submodules is not dependency management!

Self-hosting snapshots of dependency sources is not dependency management!

#### Build interface up front

The OOP idea behind encapsulation is that there is a public interface to an object and users need not concern
themselves with how the sausage is made. This is true for build interfaces as well. Surface any option, setting which
has an effect on the build near the top of the root `CMakeLists.txt` file. It may be tempting to introduce said options
near the module or the use-site, but it contradicts with easy discoverability of your build interface.

LLVM notoriously violates this, all modules introducing their options in their respective folders, thus forcing the user
to traverse dozens of folders just to discover all the options they are allowed to set.

#### Respect user preference

Variables starting with `CMAKE_` and `CPACK_` are generally owned by the user. They are global variables controlling
many of the default values for most properties on targets. Users will get frustrated if they set `CMAKE_CXX_FLAGS`
during configuration and realize that some parts (or the entire) build don't respect the values put in there.

> Do not think as a project owner that you are smarter than your users!

Carefully consider when and how you make changes to these variables. Preference, even as a project owner, is weightless
as opposed to user preference. A recurring mistake is hardcoding "warnings as errors" in some form, because the project
aspires to build cleanly. Do not enforce that on your users! They may be using newer or totally different compilers
than those available to your project. Enforce this in CI, but not on all of your users. ABI controlling flags are no
different in this regard. Even if some ABI configuration is known to misbehave, at most issue a silencable diagnostic.

#### Principle of least surprise / don't alter defaults

Changing the defaults will surprise people. Don't think that your users are all novices or that they need to be
saved from themselves. Changing defaults, such as
[`CMAKE_BUILD_TYPE`](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html) is an
([anti-pattern](https://github.com/ROCmSoftwarePlatform/rocPRIM/blob/b54aaa79eaafd351d7ce3373468211eb42ecf31a/CMakeLists.txt#L50-L55)).
Changing defaults out of personal preference is even worse. Seasoned users of a tool will know the defaults and expect
them to be what they are. Overriding that will frustrate them to no end, even if you think some default is dangerous to
novices.

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

##### Shortcomings of CMake presets

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
