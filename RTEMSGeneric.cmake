################################################################################
# Generic RTEMS configuration
################################################################################

# This function performs the generic RTEMS configuration. It expects
# following arguments:
# 1. Target/executable name
# 2. RTEMS installation prefix, path where the RTEMS toolchain is installed
# 3. RTEMS BSP, which consists generally has the format <Architecture>/<BSP>
function(rtems_generic_config TARGET_NAME RTEMS_INST RTEMS_BSP)

set(RTEMS_VERSION "" CACHE STRING "RTEMS version")

message(STATUS "Setting up and checking RTEMS cross compile configuration..")
if (RTEMS_INST STREQUAL "")
	message(FATAL_ERROR "RTEMS toolchain path has to be specified!")
endif()  

if(RTEMS_VERSION STREQUAL "")
    message(STATUS "No RTEMS_VERSION supplied.")
    message(STATUS "Autodetermining version from prefix ${RTEMS_INST} ..")
    string(REGEX MATCH [0-9]+$ RTEMS_VERSION "${RTEMS_INST}")
    message(STATUS "Version ${RTEMS_VERSION} found")
endif()

string(REPLACE "/" ";" RTEMS_BSP_LIST_SEPARATED ${RTEMS_BSP})
list(LENGTH RTEMS_BSP_LIST_SEPARATED BSP_LIST_SIZE)

if(NOT ${BSP_LIST_SIZE} EQUAL 2)
    message(FATAL_ERROR "Supplied RTEMS_BSP variable invalid. Make sure to provide a slash separated string")
endif()

list(GET RTEMS_BSP_LIST_SEPARATED 0 RTEMS_ARCH_NAME)
list(GET RTEMS_BSP_LIST_SEPARATED 1 RTEMS_BSP_NAME)

set(RTEMS_ARCH_TOOLS "${RTEMS_ARCH_NAME}-rtems${RTEMS_VERSION}")

if(IS_DIRECTORY "${RTEMS_INST}/${RTEMS_ARCH_TOOLS}")
	set(RTEMS_BSP_LIB_PATH "${RTEMS_INST}/${RTEMS_ARCH_TOOLS}/${RTEMS_BSP_NAME}/lib")
	if(NOT IS_DIRECTORY "${RTEMS_BSP_LIB_PATH}") 
		message(FATAL_ERROR "RTEMS BSP lib folder not found at ${RTEMS_BSP_LIB_PATH}")
	endif()
	set(RTEMS_BSP_INC_PATH "${RTEMS_BSP_LIB_PATH}/include")
	if(NOT IS_DIRECTORY "${RTEMS_BSP_INC_PATH}")
		message(FATAL_ERROR "RTEMS BSP include folder not found at ${RTEMS_BSP_INC_PATH}")
	endif()
else()
	message(FATAL_ERROR "RTEMS Architecure folder not found at ${RTEMS_INST}/${RTEMS_ARCH_TOOLS}")
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

target_link_directories(${TARGET_NAME} PUBLIC
	${RTEMS_BSP_LIB_PATH})
target_include_directories(${TARGET_NAME} PUBLIC
	${RTEMS_BSP_INC_PATH})
	
###############################################################################
# Setting variables in upper scope (only the upper scope!)
###############################################################################

set(CMAKE_C_COMPILER ${RTEMS_GCC} PARENT_SCOPE)
set(CMAKE_CXX_COMPILER ${RTEMS_GXX} PARENT_SCOPE)
set(CMAKE_ASM_COMPILER ${RTEMS_ASM} PARENT_SCOPE)
set(CMAKE_LINKER ${RTEMS_LINKER} PARENT_SCOPE)

endfunction()
