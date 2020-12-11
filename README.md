# rtems-cmake

This repostiory contains the first version of a possible RTEMS CMake build aupport. The intention is to export the RTEMS specific configuration of the cross compiler toolchain and the flags to external `*.cmake` files so the application `CMakeLists.txt` can stay clean, similarly to the `rtems_waf` support.

## How to use

Include the `RTEMSGeneric.cmake` file in CMake and call the `rtems_generic_config` function, passing the RTEMS installation path (also commonly called prefix)
and the RTEMS BSP (e.g. sparc/erc32) to this function.

## Extending the build system support

This is still a prototype. It has been tested for the Hello World demo from the RTEMS quick start guide which uses the `sparc/erc32` BSP and for a STM32 blinky using the `arm/stm32h7` BSP.

Extending the build support is relatively easy: 

Extract the necessary compiler and linker flags for the RTEMS build from the pkgconfig file
for the specific BSP. This file will generally be located inside the `lib/pkgconfig` folder of the RTEMS tools folder. Add these flags in the `RTEMSHardware.cmake` file for your specific BSP.

When building with CMake, `-v` can be added to verify the flags.

## Example

See https://github.com/rmspacefish/rtems-demo/tree/master/applications/hello for an example. This is the Hello World project taken from the RTEMS quick start guide,
but compiled using RTEMS. The repository also contains instructions on how to build the RTEMS tools if required and all specific steps to build with CMake.
