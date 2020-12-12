# RTEMS CMake Build Support

This repostiory contains the first version of a possible RTEMS CMake build aupport. The intention is to provide most CMake configuration to perform cross-compiling of RTEMS applications and provide a decent starting point for developers which would like to build their RTEMS application CMake. The support has been written as generic as possible.

This is still a prototype. Simple applications have been tested, but it has not been attempted to link an additional library for an application yet.

## How to use

Clone this repository. This does not necesarilly have to be in the application root path, but the RTEMS configuration path (the folder containing the `*.cmake` files) needs to be specified in this case.

```sh
git clone https://github.com/rmspacefish/rtems-cmake.git
```

After that, it is recommended to set the path to the RTEMS CMake support with the 
following line in the application `CMakeLists.txt`

```sh
set(RTEMS_CONFIG_DIR
	"<Path to RTEMS CMake support folder>"
	 CACHE FILEPATH "Directory containing the RTEMS *.cmake files"
)
```

It is also recommended to add the following lines before the `project()` call in
the application `CMakeLists.txt`:

```sh
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_CROSSCOMPILING 1)
```

This will disable the compiler checks for the standard C/C++ compiler.


If this repository was cloned inside the application root, the path can be 
set to `${CMAKE_CURRENT_SOURCE_DIRECTORY}/rtems-cmake`.

After that, include the general configuration file with the following line:

```sh
include("${RTEMS_CONFIG_DIR}/RTEMSConfig.cmake")
```

And then call the configuration function:

```sh
rtems_general_config(${CMAKE_PROJECT_NAME} ${RTEMS_PREFIX} ${RTEMS_BSP})
```

This function will call the the `rtems_generic_config` function internally to set up the cross-compiler, using the provided RTEMS prefix and the BSP name,
and the RTEMS BSP (e.g. sparc/erc32) to this function.

After that, it will call the the function `rtems_hw_config` which will assign necessary compiler and linker flags to the provided target.

## Optional configuration of the CMake support

The RTEMS CMake build support can be configured either by passing configuration options prepended with `-D` to the build command or by setting these build variables in the application `CMakeLists.txt` before calling the build support. Following options are available

 - `RTEMS_VERSION`: Can be specified manually. If this is not specified, the CMake build support will attempt to extract the version number from the RTEMS prefix (last letter of path). This variable needs to be valid for the RTEMS support to work!
 - `RTEMS_VERBOSE`: Enable additional diagnostic output.
 - `RTEMS_SCAN_PKG_CONFIG`: The RTEMS CMake support will try to read the pkgconfig files to extract compile and link flag options.
 - `RTEMS_TOOLS`: Can be specified if the RTEMS tools folder. Can be different from the prefix but will be equal to the prefix for most users.
 - `RTEMS_PATH`: Folder containing the RTEMS installation (BSPs). Can be different from the prefix but will be equal to the prefix for most users.

## Extending the build system support

It is possible to read the pkfconfig files now, so extending the manual build configuration might not be necessary in the future.

Extending the build support is relatively easy: 

Extract the necessary compiler and linker flags for the RTEMS build from the pkgconfig file
for the specific BSP. This file will generally be located inside the `lib/pkgconfig` folder of the RTEMS tools folder. Add these flags in the `RTEMSHardware.cmake` file for your specific BSP.

When building with CMake, `-v` can be added to verify the flags.

## Example

See https://github.com/rmspacefish/rtems-demo/tree/master/applications/hello for an example. This is the Hello World project taken from the RTEMS quick start guide,
but compiled using RTEMS. The repository also contains instructions on how to build the RTEMS tools if required and all specific steps to build with CMake.
