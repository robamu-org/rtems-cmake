# rtems-cmake

This repostiory contains the first version of a possible RTEMS CMake build aupport. The intention is to export the RTEMS specific configuration of the cross compiler toolchain and the flags to external `*.cmake` files so the application `CMakeLists.txt` can stay clean, similarly to the `rtems_waf` support.
