################################################################################
# RTEMS pre-project configuration
################################################################################

# This function performs the generic RTEMS configuration. Following function
# arguments are mandatory:
#
# 1. RTEMS prefix. This is generally the path where the RTEMS tools and BSPs
#    are installed. More experienced users can use multiple prefixes.
#	 This value will be cached inside the RTEMS_PREFIX variable.
# 2. RTEMS BSP pair name, which consists generally has the 
#    format <Architecture>/<BSP>. This variable will be cached inside
#    the RTEMS_BSP variable.
#
# Other variables which can be provided by the developer via command line
# (or as an environmental variable) as well:
#
# 1. RTEMS_VERSION:
#    The user can supply RTEMS_VERSION to specify the RTEMS version
#    manually. This is required to determine the toolchains to use. If no
#    RTEMS_VERSION is supplied, this CMake file will try to autodetermine the 
#    RTEMS version from the supplied tools path.
# 2. RTEMS_TOOLS:
#	 The user can provide this file path variable if the RTEMS tools path is 
#    not equal to the RTEMS prefix.
# 3. RTEMS:
#	 The user can provide this file path variable if the RTEMS path (containig
#    the BSPs) is not equal to the RTEMS prefix.
# 4. RTEMS_VERBOSE:
#    Verbose debug output for the CMake handling.
# 5. RTEMS_SCAN_PKG_CONFIG:
#    CMake will try to scan the pkgconfig file for the specified Architecture-
#    Version-BSP combination to find the compiler and linker flags.
################################################################################

function(rtems_pre_project_config RTEMS_PREFIX RTEMS_BSP)
	
option(RTEMS_VERBOSE "Additional RTEMS CMake configuration information" FALSE)

if(NOT DEFINED RTEMS_CONFIG_DIR) 
	message(STATUS 
		"RTEMS_CONFIG_DIR not set. Assuming the CMake support was "
		"cloned in the application source directory.."
	)
	set(RTEMS_CONFIG_DIR ${CMAKE_CURRENT_SOURCE_DIR}/rtems-cmake)
endif()
	
include(${RTEMS_CONFIG_DIR}/RTEMSCompilerConfig.cmake)
rtems_compiler_config(${RTEMS_PREFIX} ${RTEMS_BSP})

include(${RTEMS_CONFIG_DIR}/RTEMSPkgConfig.cmake)
rtems_pkg_config()

set(ENV{RTEMS_PREFIX} ${RTEMS_PREFIX})
set(ENV{RTEMS_BSP} ${RTEMS_BSP})
set(ENV{RTEMS_VERSION} ${RTEMS_VERSION})
if(NOT DEFINED ENV{RTEMS_TOOLS})
	set(ENV{RTEMS_TOOLS} ${RTEMS_TOOLS})
endif()
set(ENV{RTEMS_BSP_NAME} ${RTEMS_BSP_NAME})
set(ENV{RTEMS_ARCH_NAME} ${RTEMS_ARCH_NAME})
set(ENV{RTEMS_ARCH_VERSION_NAME} ${RTEMS_ARCH_VERSION_NAME})

endfunction()