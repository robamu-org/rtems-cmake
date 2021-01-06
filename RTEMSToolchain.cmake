###############################################################################
# CMake RTEMS support toolchain file.
#
# This file is the intended way in CMake to set up CMake for cross-compilation.
# Following environmental variables need to be set by user or by upper 
# CMakeLists.txt:
# 
# 1. RTEMS_TOOLS: Location of the RTEMS tools
# 2. RTEMS_ARCH_VERSION_NAME: Identifier with the format <ARCH>-rtems<VERSION>
#
# The toolchain file will determine and try to find the compilers based 
# on these environmental variables.
# Environmental variables can be set in a CMakeLists.txt with the following
# command (do this before calling project()!)
#
# set(ENV{RTEMS_TOOLS} "<PATH_TO_TOOLS>")
#
###############################################################################
# Finding compilers by using environment variables.
###############################################################################

set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSTEM_NAME Generic)

if(NOT DEFINED ENV{RTEMS_ARCH_VERSION_NAME})
	message(FATAL_ERROR "RTEMS_ARCH_VERSION_NAME variable not set!")
endif()

if(NOT DEFINED ENV{RTEMS_TOOLS})
	message(FATAL_ERROR "RTEMS_TOOLS variable not set!")
endif()

if(NOT DEFINED ENV{CMAKE_ONLY_PRINT_ONCE_HACK})
	message(STATUS "Checking for RTEMS binaries folder..")
endif()

set(RTEMS_BIN_PATH "$ENV{RTEMS_TOOLS}/bin")
if(NOT IS_DIRECTORY "${RTEMS_BIN_PATH}")
	message(FATAL_ERROR "RTEMS binaries folder not found at ${RTEMS_BIN_PATH}")
endif()

list(APPEND CMAKE_PREFIX_PATH "${RTEMS_TOOLS}")

set(CROSS_COMPILE_CC "$ENV{RTEMS_ARCH_VERSION_NAME}-gcc")
set(CROSS_COMPILE_CXX "$ENV{RTEMS_ARCH_VERSION_NAME}-g++")
set(CROSS_COMPILE_SIZE "$ENV{RTEMS_ARCH_VERSION_NAME}-size")

# Check that compilers are available.
find_program(RTEMS_GCC "${CROSS_COMPILE_CC}" REQUIRED)
find_program(RTEMS_GXX "${CROSS_COMPILE_CXX}" REQUIRED)

# Size utility optional.
find_program (CMAKE_SIZE ${CROSS_COMPILE_SIZE})


if($ENV{RTEMS_ARCH_NAME} STREQUAL "arm")
    set(CMAKE_SYSTEM_PROCESSOR arm)
elseif ($ENV{RTEMS_ARCH_NAME} STREQUAL "sparc")
	set(CMAKE_SYSTEM_PROCESSOR sparc)
endif()
	
###############################################################################
# Setting compiler and flags
###############################################################################

set(CMAKE_C_COMPILER ${RTEMS_GCC})
set(CMAKE_CXX_COMPILER ${RTEMS_GXX})

string (REPLACE ";" " " RTEMS_BSP_CONFIG_CFLAGS "${RTEMS_BSP_CONFIG_CFLAGS}")
string (REPLACE ";" " " RTEMS_BSP_CONFIG_LDFLAGS "${RTEMS_BSP_CONFIG_LDFLAGS}")

set(CMAKE_C_FLAGS ${RTEMS_BSP_CONFIG_CFLAGS})
set(CMAKE_CXX_FLAGS ${CMAKE_C_FLAGS})

# This does not work and I don't know why. Need to set this after project 
# definition or the linker test will fail.
set(CMAKE_EXE_LINKER_FLAGS_INIT ${RTEMS_BSP_CONFIG_LDFLAGS})

# https://cmake.org/cmake/help/latest/variable/CMAKE_TRY_COMPILE_TARGET_TYPE.html
# This prevents the issue of the linker not able to link a test program.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(ENV{CMAKE_ONLY_PRINT_ONCE_HACK} TRUE)