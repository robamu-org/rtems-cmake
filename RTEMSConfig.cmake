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
# as well:
#
# 1. RTEMS_VERSION:
#    The user can supply RTEMS_VERSION to specify the RTEMS version
#    manually. This is required to determine the toolchains to use. If no
#    RTEMS_VERSION is supplied, this CMake file will try to autodetermine the 
#    RTEMS version from the supplied tools path.
# 2. RTEMS_TOOLS:
#	 The user can provide this filepath variable if the RTEMS tools path is 
#    not equal to the RTEMS prefix.
# 3. RTEMS_PATH:
#	 The user can provide this filepath variable if the RTEMS path (containg
#    the BSPs) is not equal to the RTEMS prefix.
# 
# Any additional arguments will be passed on to the subfunctions here.

function(rtems_general_config TARGET_NAME RTEMS_PREFIX RTEMS_BSP_PAIR)

	include(${RTEMS_CONFIG_DIRECTORY}/RTEMSGeneric.cmake)
	rtems_generic_config(${TARGET_NAME} ${RTEMS_PREFIX} ${RTEMS_BSP_PAIR} ${ARGN})
	
	# Not an ideal solution but it will do for now because the number of 
	# variables which need to be propagated to the upper most CMakeLists.txt
	# should not become too high.
	# We could also use CMAKE_TOOLCHAIN_FILE but this way works as well.
	set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER} PARENT_SCOPE)
	set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER} PARENT_SCOPE)
	set(CMAKE_ASM_COMPILER ${CMAKE_ASM_COMPILER} PARENT_SCOPE)
	set(CMAKE_LINKER ${CMAKE_LINKER} PARENT_SCOPE)
	
	# I don't know what this is used for yet, but it might become handy
	if(NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
		set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR} PARENT_SCOPE)
	endif()
	
	include(${RTEMS_CONFIG_DIRECTORY}/RTEMSHardware.cmake)
	rtems_hw_config(${TARGET_NAME} ${RTEMS_PREFIX} ${RTEMS_BSP_PAIR} ${ARGN})

	# No propagation necessary here because we can use target specific settings.

endfunction()
