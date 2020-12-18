################################################################################
# Generic RTEMS configuration
################################################################################

# This function performs the generic RTEMS configuration. Following function
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
# 3. RTEMS:
#	 The user can provide this filepath variable if the RTEMS path (containig
#    the BSPs) is not equal to the RTEMS prefix.

function(rtems_generic_config TARGET_NAME RTEMS_PREFIX RTEMS_BSP_PAIR)

set (EXTRA_RTEMS_ARGS ${ARGN})
list(LENGTH EXTRA_RTEMS_ARGS NUM_EXTRA_RTEMS_ARGS)

if (${NUM_EXTRA_RTEMS_ARGS} EQUAL 1)
	# This only works for one optional arguments! Need to write list to 
	# single variables if this is extended.
	set(RTEMS ${EXTRA_RTEMS_ARGS})
endif()

if(NOT RTEMS_PREFIX)
	status(WARNING "No RTEMS prefix supplied!")
endif()


set(RTEMS_PREFIX ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS prefix")
get_filename_component(RTEMS_PREFIX "${RTEMS_PREFIX}" ABSOLUTE)
set(RTEMS_PREFIX_ABS ${RTEMS_PREFIX} CACHE FILEPATH 
	"RTEMS prefix (absolute path)"
)
	
set(RTEMS_BSP ${RTEMS_BSP} CACHE STRING "RTEMS BSP pair")


option(RTEMS_VERBOSE "Verbose output for the RTEMS CMake support" FALSE)

set(RTEMS_INSTALL 
	${CMAKE_INSTALL_PREFIX} 
	CACHE FILEPATH "RTEMS install destination"
)

if(NOT RTEMS)
	message(STATUS 
		"RTEMS path was not specified and was set to RTEMS prefix."
	)
	set(RTEMS ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS folder")
endif()

if(NOT RTEMS_TOOLS)
	message(STATUS 
		"RTEMS toolchain path was not specified and was set to RTEMS prefix."
	)
	set(RTEMS_TOOLS ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS tools folder")
endif()

if(NOT RTEMS_VERSION)
	message(STATUS "No RTEMS_VERSION supplied.")
    message(STATUS "Autodetermining version from tools path ${RTEMS_TOOLS} ..")
    string(REGEX MATCH [0-9]+$ RTEMS_VERSION "${RTEMS_TOOLS}")
    message(STATUS "Version ${RTEMS_VERSION} found")
endif()

set(RTEMS_VERSION "${RTEMS_VERSION}" CACHE STRING "RTEMS version")

message(STATUS "Setting up and checking RTEMS cross compile configuration..")

string(REPLACE "/" ";" RTEMS_BSP_LIST_SEPARATED ${RTEMS_BSP_PAIR})
list(LENGTH RTEMS_BSP_LIST_SEPARATED BSP_LIST_SIZE)

if(NOT ${BSP_LIST_SIZE} EQUAL 2)
    message(FATAL_ERROR 
    	"Supplied RTEMS_BSP variable invalid. " 
    	"Make sure to provide a slash separated string"
    )
endif()

list(GET RTEMS_BSP_LIST_SEPARATED 0 RTEMS_ARCH_NAME)
list(GET RTEMS_BSP_LIST_SEPARATED 1 RTEMS_BSP_NAME)

set(RTEMS_ARCH_VERSION_NAME "${RTEMS_ARCH_NAME}-rtems${RTEMS_VERSION}")

if(NOT IS_DIRECTORY "${RTEMS_TOOLS}/${RTEMS_ARCH_VERSION_NAME}")
	message(FATAL_ERROR 
		"RTEMS architecure folder not found at "
		"${RTEMS_TOOLS}/${RTEMS_ARCH_VERSION_NAME}"
	)
endif()

set(RTEMS_ARCH_LIB_PATH "${RTEMS_TOOLS}/${RTEMS_ARCH_VERSION_NAME}/lib")
set(RTEMS_TOOLS_LIB_PATH "${RTEMS_TOOLS}/lib")

set(RTEMS_BSP_PATH "${RTEMS}/${RTEMS_ARCH_VERSION_NAME}/${RTEMS_BSP_NAME}")
if(NOT IS_DIRECTORY ${RTEMS_BSP_PATH})
	message(STATUS 
		"Supplied or autodetermined BSP path "
		"${RTEMS_BSP_PATH} is invalid!"
	)
	message(FATAL_ERROR 
		"Please check the BSP path or make sure " 
		"the BSP is installed."
	)
endif()

set(RTEMS_BSP_LIB_PATH "${RTEMS_BSP_PATH}/lib")
if(NOT IS_DIRECTORY "${RTEMS_BSP_LIB_PATH}") 
	message(FATAL_ERROR 
		"RTEMS BSP lib folder not found at "
		"${RTEMS_BSP_LIB_PATH}"
	)
endif()
set(RTEMS_BSP_INC_PATH "${RTEMS_BSP_LIB_PATH}/include")
if(NOT IS_DIRECTORY "${RTEMS_BSP_INC_PATH}")
	message(FATAL_ERROR 
		"RTEMS BSP include folder not found at "
		"${RTEMS_BSP_INC_PATH}"
	)
endif()


################################################################################
# Checking the toolchain
################################################################################

if(CMAKE_HOST_WIN32)
	set(WIN_SUFFIX ".exe")
endif()

message(STATUS "Checking for RTEMS binaries folder..")
set(RTEMS_BIN_PATH "${RTEMS_TOOLS}/bin")
if(NOT IS_DIRECTORY "${RTEMS_BIN_PATH}")
	message(FATAL_ERROR "RTEMS binaries folder not found at ${RTEMS_TOOLS}/bin")
endif()

message(STATUS "Checking for RTEMS gcc..")
set(RTEMS_GCC "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-gcc${WIN_SUFFIX}")
if(NOT EXISTS "${RTEMS_GCC}") 
	message(FATAL_ERROR 
		"RTEMS gcc compiler not found at "
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-gcc${WIN_SUFFIX}"
	)
endif()

message(STATUS "Checking for RTEMS g++..")
set(RTEMS_GXX "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-g++${WIN_SUFFIX}")
if(NOT EXISTS "${RTEMS_GXX}")
	message(FATAL_ERROR 
		"RTEMS g++ compiler not found at " 
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-g++${WIN_SUFFIX}"
	)
endif()

message(STATUS "Checking for RTEMS assembler..")
set(RTEMS_ASM "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-as${WIN_SUFFIX}")
if(NOT EXISTS "${RTEMS_GXX}")
	message(FATAL_ERROR 
		"RTEMS as compiler not found at " 
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-as${WIN_SUFFIX}")
endif()

message(STATUS "Checking for RTEMS linker..")
set(RTEMS_LINKER "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-ld${WIN_SUFFIX}")
if(NOT EXISTS "${RTEMS_LINKER}")
	message(FATAL_ERROR 
		"RTEMS ld linker  not found at "
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-ld${WIN_SUFFIX}")
endif()

message(STATUS "Checking for RTEMS objcopy utility..")
set(RTEMS_OBJCOPY 
	"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-objcopy${WIN_SUFFIX}"
)
if(NOT EXISTS "${RTEMS_OBJCOPY}")
	message(WARNING
		"RTEMS ld linker  not found at ${RTEMS_OBJCOPY}")
endif()

message(STATUS "Checking for RTEMS size utility..")
set(RTEMS_SIZE "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-size${WIN_SUFFIX}")
if(NOT EXISTS "${RTEMS_SIZE}")
	message(WARNING
		"RTEMS ld linker  not found at ${RTEMS_SIZE}")
endif()

message(STATUS "Checking done.")

############################################
# Info output
###########################################

message(STATUS "RTEMS version: ${RTEMS_VERSION}")
message(STATUS "RTEMS prefix: ${RTEMS_PREFIX}")
message(STATUS "RTEMS tools path: ${RTEMS_TOOLS}")
message(STATUS "RTEMS BSP pair: ${RTEMS_BSP}")
message(STATUS "RTEMS architecture tools path: "
	"${RTEMS}/${RTEMS_ARCH_VERSION_NAME}")
message(STATUS "RTEMS BSP library path: ${RTEMS_BSP_LIB_PATH}")
message(STATUS "RTEMS BSP include path: ${RTEMS_BSP_INC_PATH}")
message(STATUS "RTEMS install target: ${RTEMS_INSTALL}")

message(STATUS "RTEMS gcc compiler: ${RTEMS_GCC}")
message(STATUS "RTEMS g++ compiler: ${RTEMS_GXX}")
message(STATUS "RTEMS assembler: ${RTEMS_ASM}")
message(STATUS "RTEMS linker: ${RTEMS_LINKER}")
message(STATUS "RTEMS objcopy: ${RTEMS_OBJCOPY}")
message(STATUS "RTEMS objcopy: ${RTEMS_SIZE}")


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
set(RTEMS_OBJCOPY ${RTEMS_OBJCOPY} CACHE FILEPATH "RTEMS objcopy utilits")
set(RTEMS_SIZE ${RTEMS_SIZE} CACHE FILEPATH "RTEMS size utility")

# Variables set in the cache so they can be used everywhere.
set(RTEMS_ARCH_NAME ${RTEMS_ARCH_NAME} CACHE FILEPATH "Architecture name")
set(RTEMS_BSP_NAME ${RTEMS_BSP_NAME} CACHE FILEPATH "BSP name")
set(RTEMS_TOOLS_LIB_PATH ${RTEMS_TOOLS_LIB_PATH} 
	CACHE FILEPATH "Tools library path"
)
set(RTEMS_BSP_LIB_PATH ${RTEMS_BSP_LIB_PATH} CACHE FILEPATH "BSP library path")
set(RTEMS_BSP_INC_PATH ${RTEMS_BSP_INC_PATH} CACHE FILEPATH "BSP include path")
set(RTEMS_ARCH_LIB_PATH ${RTEMS_ARCH_LIB_PATH} 
	CACHE FILEPATH "Architecture library path"
)
set(RTEMS_ARCH_VERSION_NAME ${RTEMS_ARCH_VERSION_NAME} 
	CACHE FILEPATH "Unique architecture-version identifier"
)

list(APPEND CMAKE_PREFIX_PATH ${RTEMS_BSP_LIB_PATH})
list(APPEND CMAKE_PREFIX_PATH ${RTEMS_BSP_INC_PATH})
list(APPEND CMAKE_PREFIX_PATH ${RTEMS_ARCH_LIB_PATH})
list(APPEND CMAKE_PREFIX_PATH ${RTEMS_TOOLS_LIB_PATH})

set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)

endfunction()
