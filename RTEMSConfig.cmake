########################################
# General RTEMS configuration
########################################

# This function performs the generic RTEMS configuration. It expects
# following arguments:
# 1. Target/executable name
# 2. Path to the RTEMS tools
# 3. RTEMS BSP pair name, which consists generally has the 
#    format <Architecture>/<BSP>
#
# Following function arguments are optional and can simply be supplied
# behind the last mandatory argument in the right order:
# 
# 1. RTEMS BSP path. The BSP might be installed in a different path. If this is 
#    not supplied, this path will be autodetermined from the BSP pair name 
#    and the RTEMS tools path. The full path has to be specified for now.
#
# In addition, the user can supply RTEMS_VERSION to specify the RTEMS version
# manually. This is required to determine the toolchains to use. If no
# RTEMS_VERSION is supplied, this CMake file will try to autodetermine the 
# RTEMS version from the supplied tools path.

function(rtems_general_config TARGET_NAME RTEMS_INST RTEMS_BSP_PAIR)

	set(RTEMS_BSP_LIB_PATH CACHE INTERNAL "")
	set(RTEMS_BSP_INC_PATH CACHE INTERNAL "")
	set(RTEMS_ARCH_LIB_PATH CACHE INTERNAL "")
	
	include(${RTEMS_CONFIG_DIRECTORY}/RTEMSGeneric.cmake)
	rtems_generic_config(${TARGET_NAME} ${RTEMS_INST} ${RTEMS_BSP_PAIR} ${ARGN})
	
	# Not an ideal solution but it will do for now because the number of 
	# variables which need to be propagated to the upper most CMakeLists.txt
	# should not become too high.
	set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER} PARENT_SCOPE)
	set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER} PARENT_SCOPE)
	set(CMAKE_ASM_COMPILER ${CMAKE_ASM_COMPILER} PARENT_SCOPE)
	set(CMAKE_LINKER ${CMAKE_LINKER} PARENT_SCOPE)
	set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} PARENT_SCOPE)
	
	# I don't know what this is used for yet, but it might become handy
	if(NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
		set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR} PARENT_SCOPE)
	endif()
	
	include(${RTEMS_CONFIG_DIRECTORY}/RTEMSHardware.cmake)
	rtems_hw_config(${TARGET_NAME} ${RTEMS_INST} ${RTEMS_BSP})

	# No propagation necessary here because we can use target specific settings.

endfunction()
