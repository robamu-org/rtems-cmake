# rtems-cmake

This repostiory contains the first version of a possible RTEMS CMake build aupport. The intention is to export the RTEMS specific configuration of the cross compiler toolchain and the flags to external `*.cmake` files so the application `CMakeLists.txt` can stay clean, similarly to the `rtems_waf` support.

## How to use

Include the `RTEMSGeneric.cmake` file in CMake and call the `rtems_generic_config` function, passing the RTEMS installation path (also commonly called prefix)
and the RTEMS BSP (e.g. sparc/erc32) to this function.

## Example

See https://github.com/rmspacefish/rtems-demo/tree/master/applications/hello for an example. This is the Hello World project taken from the RTEMS quick start guide,
but compiled using RTEMS. The repository also contains instructions on how to build the RTEMS tools if required and all specific steps to build with CMake.
