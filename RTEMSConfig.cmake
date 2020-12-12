################################################################################
# RTEMS configuration
################################################################################

# This function performs RTEMS configuration. Following function
# arguments are mandatory:
#
# 1. Target/executable name
# 2. RTEMS prefix. This is generally the path where the RTEMS tools and BSPs
#    are installed. More experienced users can use multiple prefixes.
#	 This value will be cached inside the RTEMS_PREFIX variable.
# 3. RTEMS BSP pair name, which consists generally has the 
#    format <Architecture>/<BSP>. This variable will be cached inside
#    the RTEMS_BSP variable.
#
# Other variables which can be provided by the developer via command line
# or in the application CMake file as well:
#
# 1. RTEMS_CONFIG_DIR: The application will assume that all other configuration
#    files are located in this path or relative to this path. If this is not set
#    it will be set to the ${CMAKE_CURRENT_SOURCE_DIR}/rtems-cmake
# 2. RTEMS_VERSION:
#    The user can supply RTEMS_VERSION to specify the RTEMS version
#    manually. This is required to determine the toolchains to use. If no
#    RTEMS_VERSION is supplied, this CMake file will try to autodetermine the 
#    RTEMS version from the supplied tools path.
# 3. RTEMS_TOOLS:
#	 The user can provide this filepath variable if the RTEMS tools path is 
#    not equal to the RTEMS prefix.
# 4. RTEMS_PATH:
#	 The user can provide this filepath variable if the RTEMS path (containg
#    the BSPs) is not equal to the RTEMS prefix.
# 5. RTEMS_VERBOSE:
#    Verbose debug output for the CMake handling.
# 6. RTEMS_SCAN_PKG_CONFIG:
#    CMake will try to scan the pkgconfig file for the specified Architecture-
#    Version-BSP combination to find the compiler and linker flags.
# 
# Any additional arguments will be passed on to the subfunctions here.

function(rtems_general_config TARGET_NAME RTEMS_PREFIX RTEMS_BSP_PAIR)

	message(STATUS ${RTEMS_CONFIG_DIR})
	if(NOT RTEMS_CONFIG_DIR) 
		message(STATUS 
			"RTEMS_CONFIG_DIR not set. Assuming  the CMake support was "
			"cloned in the application source directory.."
		)
		set(RTEMS_CONFIG_DIR ${CMAKE_CURRENT_SOURCE_DIR}/rtems-cmake)
	endif()
	
	include(${RTEMS_CONFIG_DIR}/RTEMSGeneric.cmake)
	rtems_generic_config(${TARGET_NAME} ${RTEMS_PREFIX} ${RTEMS_BSP_PAIR} ${ARGN})
	
	# Not an ideal solution but it will do for now because the number of 
	# variables which need to be propagated to the upper most CMakeLists.txt
	# should not become too high.
	# We could also use CMAKE_TOOLCHAIN_FILE but this way works as well and we 
	# dont have to supply the file each time, we can set the location in
	# the uppermost CMakeLists.txt once.

	set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER} PARENT_SCOPE)
	set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER} PARENT_SCOPE)
	set(CMAKE_ASM_COMPILER ${CMAKE_ASM_COMPILER} PARENT_SCOPE)
	set(CMAKE_LINKER ${CMAKE_LINKER} PARENT_SCOPE)
		
	# I don't know what this is used for yet, but it might become handy
	if(NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
		set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR} PARENT_SCOPE)
	endif()
	
	include(${RTEMS_CONFIG_DIR}/RTEMSHardware.cmake)
	rtems_hw_config(${TARGET_NAME} ${RTEMS_PREFIX} ${RTEMS_BSP_PAIR} ${ARGN})

	# No propagation necessary here because we can use target specific settings.

endfunction()
