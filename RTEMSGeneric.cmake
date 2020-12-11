################################################################################
# Generic RTEMS configuration
################################################################################

# This function performs the generic RTEMS configuration. Following function
# arguments are mandatory:
#
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

function(rtems_generic_config TARGET_NAME RTEMS_TOOLS RTEMS_BSP_PAIR)

set (EXTRA_RTEMS_ARGS ${ARGN})
list(LENGTH EXTRA_RTEMS_ARGS NUM_EXTRA_RTEMS_ARGS)

if (${NUM_EXTRA_RTEMS_ARGS} EQUAL 1)
	# This only works for one optional arguments! Need to write list to 
	# single variables if this is extended.
	set(RTEMS_BSP_PATH ${EXTRA_RTEMS_ARGS})
endif()

set(RTEMS_VERSION "" CACHE STRING "RTEMS version")
set(RTEMS_PREFIX "" CACHE FILEPATH "Install prefix")

if(${RTEMS_PREFIX} NOT STREQUAL "")
	# For now, a provided RTEMS_PREFIX will simply overwrite the default 
	# CMake install location.
	set(CMAKE_INSTALL_PREFIX ${RTEMS_PREFIX} PARENT_SCOPE)
endif()
	
message(STATUS "Setting up and checking RTEMS cross compile configuration..")
if (RTEMS_TOOLS STREQUAL "")
	message(FATAL_ERROR "RTEMS toolchain path has to be specified!")
endif()  

if(RTEMS_VERSION STREQUAL "")
    message(STATUS "No RTEMS_VERSION supplied.")
    message(STATUS "Autodetermining version from tools path ${RTEMS_INST} ..")
    string(REGEX MATCH [0-9]+$ RTEMS_VERSION "${RTEMS_INST}")
    message(STATUS "Version ${RTEMS_VERSION} found")
endif()

string(REPLACE "/" ";" RTEMS_BSP_LIST_SEPARATED ${RTEMS_BSP_PAIR})
list(LENGTH RTEMS_BSP_LIST_SEPARATED BSP_LIST_SIZE)

if(NOT ${BSP_LIST_SIZE} EQUAL 2)
    message(FATAL_ERROR "Supplied RTEMS_BSP variable invalid. Make sure to provide a slash separated string")
endif()

list(GET RTEMS_BSP_LIST_SEPARATED 0 RTEMS_ARCH_NAME)
list(GET RTEMS_BSP_LIST_SEPARATED 1 RTEMS_BSP_NAME)

set(RTEMS_ARCH_TOOLS "${RTEMS_ARCH_NAME}-rtems${RTEMS_VERSION}")

if(NOT IS_DIRECTORY "${RTEMS_TOOLS}/${RTEMS_ARCH_TOOLS}")
	message(FATAL_ERROR "RTEMS Architecure folder not found at ${RTEMS_TOOLS}/${RTEMS_ARCH_TOOLS}")
endif()

if(IS_DIRECTORY "${RTEMS_INST}/${RTEMS_ARCH_TOOLS}/lib")
	set(RTEMS_ARCH_LIB_PATH "${RTEMS_INST}/${RTEMS_ARCH_TOOLS}/lib" PARENT_SCOPE)
endif()
    
# This can also be supplied as an optional argument to the function
if(NOT RTEMS_BSP_PATH) 
	# Autodetermined..
	set(STATUS "Autodetermining BSP path..")
	set(RTEMS_BSP_PATH "${RTEMS_INST}/${RTEMS_ARCH_TOOLS}/${RTEMS_BSP_NAME}")
endif()

if(NOT IS_DIRECTORY ${RTEMS_BSP_PATH})
	message(STATUS "Supplied or autodetermined BSP path ${RTEMS_BSP_PATH} is invalid!")
	message(FATAL_ERROR "Please check the BSP path or make sure the BSP is installed.")
endif()

set(RTEMS_BSP_LIB_PATH "${RTEMS_BSP_PATH}/lib")
if(NOT IS_DIRECTORY "${RTEMS_BSP_LIB_PATH}") 
	message(FATAL_ERROR "RTEMS BSP lib folder not found at ${RTEMS_BSP_LIB_PATH}")
endif()
set(RTEMS_BSP_INC_PATH "${RTEMS_BSP_LIB_PATH}/include")
if(NOT IS_DIRECTORY "${RTEMS_BSP_INC_PATH}")
	message(FATAL_ERROR "RTEMS BSP include folder not found at ${RTEMS_BSP_INC_PATH}")
endif()


################################################################################
# Checking the toolchain
################################################################################

message(STATUS "Checking for RTEMS binaries folder..")
set(RTEMS_BIN_PATH "${RTEMS_INST}/bin")
if(NOT IS_DIRECTORY "${RTEMS_BIN_PATH}")
	message(FATAL_ERROR "RTEMS binaries folder not found at ${RTEMS_INST}/bin")
endif()

message(STATUS "Checking for RTEMS gcc..")
set(RTEMS_GCC "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-gcc")
if(NOT EXISTS "${RTEMS_GCC}") 
	message(FATAL_ERROR "RTEMS gcc compiler not found at ${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-gcc")
endif()

message(STATUS "Checking for RTEMS g++..")
set(RTEMS_GXX "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-g++")
if(NOT EXISTS "${RTEMS_GXX}")
	message(FATAL_ERROR "RTEMS g++ compiler not found at ${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-g++")
endif()

message(STATUS "Checking for RTEMS assembler..")
set(RTEMS_ASM "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-as")
if(NOT EXISTS "${RTEMS_GXX}")
	message(FATAL_ERROR "RTEMS as compiler not found at ${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-as")
endif()

message(STATUS "Checking for RTEMS linker..")
set(RTEMS_LINKER "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-ld")
if(NOT EXISTS "${RTEMS_LINKER}")
	message(FATAL_ERROR "RTEMS ld linker  not found at ${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-ld")
endif()

message(STATUS "Checking done")

############################################
# Info output
###########################################

message(STATUS "RTEMS Version: ${RTEMS_VERSION}")
message(STATUS "RTEMS installation path: ${RTEMS_INST}")
message(STATUS "RTEMS Architecture tools path: ${RTEMS_ARCH_TOOLS}")
message(STATUS "RTEMS BSP: ${RTEMS_BSP}")
message(STATUS "RTEMS BSP LIB path: ${RTEMS_BSP_LIB_PATH}")
message(STATUS "RTEMS BSP INC path: ${RTEMS_BSP_INC_PATH}")

message(STATUS "RTEMS gcc compiler: ${RTEMS_GCC}")
message(STATUS "RTEMS g++ compiler: ${RTEMS_GXX}")
message(STATUS "RTEMS assembler: ${RTEMS_ASM}")
message(STATUS "RTEMS linker: ${RTEMS_LINKER}")

if(${RTEMS_ARCH_NAME} STREQUAL "arm")
    set(CMAKE_SYSTEM_PROCESSOR arm PARENT_SCOPE)
endif()
	
###############################################################################
# Setting variables in upper scope (only the upper scope!)
###############################################################################

set(CMAKE_C_COMPILER ${RTEMS_GCC} PARENT_SCOPE)
set(CMAKE_CXX_COMPILER ${RTEMS_GXX} PARENT_SCOPE)
set(CMAKE_ASM_COMPILER ${RTEMS_ASM} PARENT_SCOPE)
set(CMAKE_LINKER ${RTEMS_LINKER} PARENT_SCOPE)

set(RTEMS_BSP_LIB_PATH ${RTEMS_BSP_LIB_PATH} PARENT_SCOPE)
set(RTEMS_BSP_INC_PATH ${RTEMS_BSP_INC_PATH} PARENT_SCOPE)

endfunction()
