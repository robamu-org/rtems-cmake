################################################################################
# Generic Toolchain configuration
################################################################################
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_SYSTEM_NAME Generic)

#if(NOT IS_DIRECTORY "${RTEMS_TOOLS}/$ENV{RTEMS_ARCH_VERSION_NAME}")
#	message(FATAL_ERROR 
#		"RTEMS architecure folder not found at "
#		"${RTEMS_TOOLS}/${RTEMS_ARCH_VERSION_NAME}"
#	)
#endif()

set(RTEMS_ARCH_LIB_PATH "${RTEMS_TOOLS}/$ENV{RTEMS_ARCH_VERSION_NAME}/lib")
set(RTEMS_TOOLS_LIB_PATH "${RTEMS_TOOLS}/lib")

set(RTEMS_BSP_PATH "$ENV{RTEMS_PATH}/$ENV{RTEMS_ARCH_VERSION_NAME}/$ENV{RTEMS_BSP_NAME}")
if(NOT IS_DIRECTORY ${RTEMS_BSP_PATH})
	message(STATUS 
		"Supplied or autodetermined BSP path "
		"${RTEMS_BSP_PATH} is invalid!"
	)
	#message(FATAL_ERROR 
	#	"Please check the BSP path or make sure " 
	#	"the BSP is installed."
	#)
endif()

set(RTEMS_BSP_LIB_PATH "${RTEMS_BSP_PATH}/lib")
if(NOT IS_DIRECTORY "${RTEMS_BSP_LIB_PATH}") 
	#message(FATAL_ERROR 
	#	"RTEMS BSP lib folder not found at "
	#	"${RTEMS_BSP_LIB_PATH}"
	#)
endif()
set(RTEMS_BSP_INC_PATH "${RTEMS_BSP_LIB_PATH}/include")
if(NOT IS_DIRECTORY "${RTEMS_BSP_INC_PATH}")
	#message(FATAL_ERROR 
	#	"RTEMS BSP include folder not found at "
	#	"${RTEMS_BSP_INC_PATH}"
	#)
endif()

# This file can be loaded with -DCMAKE_TOOLCHAIN_FILE, but we need to
# disable the checks anyway.. RTEMSConfig.make prefered for now.
#if($ENV{RTEMS_SCAN_PKG_CONFIG})

	message(STATUS "Trying to load PkgConfig module..")
	find_package(PkgConfig)

	set(RTEMS_PKG_MODULE_NAME "$ENV{RTEMS_ARCH_VERSION_NAME}-$ENV{RTEMS_BSP_NAME}")
	set(RTEMS_PKG_MODULE_FILE_NAME "${RTEMS_PKG_MODULE_NAME}.pc")
	set(RTEMS_PKG_FILE_PATH "${RTEMS_TOOLS_LIB_PATH}/pkgconfig")

	if(IS_DIRECTORY "${RTEMS_PKG_FILE_PATH}")
		list(APPEND CMAKE_PREFIX_PATH "${RTEMS_PKG_FILE_PATH}")
		if(EXISTS "${RTEMS_PKG_FILE_PATH}/${RTEMS_PKG_MODULE_FILE_NAME}")
			message(STATUS "PKG configuration file for given "
				"architecture-version-BSP combination found.."
			)
		endif()
	endif()
	
	# Known bug: https://gitlab.kitware.com/cmake/cmake/-/issues/18150
	
	# Ugly solution, but have not found better way yet.
	if(CMAKE_HOST_WIN32)
		set(PATH_SEPARATOR ";")
	else()
		set(PATH_SEPARATOR ":")
	endif()
	
	set(ENV{PKG_CONFIG_PATH} 
		"$ENV{PKG_CONFIG_PATH}${PATH_SEPARATOR}${RTEMS_PKG_FILE_PATH}"
	)
	
	pkg_check_modules(RTEMS_BSP_CONFIG "${RTEMS_PKG_MODULE_NAME}")

	pkg_get_variable(RTEMS_BSP_CONFIG_PREFIX 
		"${RTEMS_PKG_MODULE_NAME}" "prefix"
	)
	if(NOT "${RTEMS_BSP_CONFIG_PREFIX}" MATCHES "${RTEMS_PREFIX_ABS}")
		message(WARNING 
			"Specified RTEMS prefix and prefix read from "
			"pkgconfig are different!"
		)
		message(WARNING 
			"Consider adapting the pkg-config file manually if "
			"the toolchain has moved and the build fails."
		)
		message(STATUS "PKG Prefix: ${RTEMS_BSP_CONFIG_PREFIX}")
		message(STATUS "Specified prefix: ${RTEMS_PREFIX_ABS}")
	endif()
	
	set(RTEMS_VERBOSE TRUE)
	
	if(${RTEMS_VERBOSE})
		message(STATUS "PKG prefix: ${RTEMS_BSP_CONFIG_PREFIX}")
		message(STATUS "PKG configuration file found: ${RTEMS_BSP_CONFIG_FOUND}")
		message(STATUS "Libraries: ${RTEMS_BSP_CONFIG_LIBRARIES}")
		message(STATUS "Link libraries: ${_RTEMS_BSP_CONFIGLINK_LIBRARIES}")
		message(STATUS "Library directories: ${RTEMS_BSP_CONFIG_LIBRARY_DIRS}")
		message(STATUS "LD flags: ${RTEMS_BSP_CONFIG_LDFLAGS}")
		message(STATUS "LD flags (other): ${RTEMS_BSP_CONFIG_LDFLAGS_OTHER}")
		message(STATUS "Include directories: ${RTEMS_BSP_CONFIG_INCLUDE_DIRS}")
		message(STATUS "CFlags: ${RTEMS_BSP_CONFIG_CFLAGS}")
		message(STATUS "CFlags (other): ${RTEMS_BSP_CONFIG_CFLAGS_OTHER}")
	endif()
	
#else()

#	set(RTEMS_BSP_CONFIG_FOUND FALSE)

#endif()


################################################################################
# Checking the toolchain
################################################################################


message(STATUS "Checking for RTEMS binaries folder..")
set(RTEMS_BIN_PATH "${RTEMS_TOOLS}/bin")
if(NOT IS_DIRECTORY "${RTEMS_BIN_PATH}")
	# message(FATAL_ERROR "RTEMS binaries folder not found at ${RTEMS_TOOLS}/bin")
endif()

list(APPEND CMAKE_PREFIX_PATH "${RTEMS_TOOLS}")

find_program(RTEMS_GCC "$ENV{RTEMS_ARCH_VERSION_NAME}-gcc" REQUIRED)
find_program(RTEMS_GXX "$ENV{RTEMS_ARCH_VERSION_NAME}-g++" REQUIRED)


#message(STATUS "Checking for RTEMS gcc..")
#set(RTEMS_GCC "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-gcc")
#if(NOT EXISTS "${RTEMS_GCC}") 
#	message(FATAL_ERROR 
#		"RTEMS gcc compiler not found at "
#		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-gcc"
#	)
#endif()

#message(STATUS "Checking for RTEMS g++..")
#set(RTEMS_GXX "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-g++")
#if(NOT EXISTS "${RTEMS_GXX}")
#	message(FATAL_ERROR 
#		"RTEMS g++ compiler not found at " 
#		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-g++"
#	)
#endif()

#message(STATUS "Checking for RTEMS assembler..")
#set(RTEMS_ASM "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-as")
#if(NOT EXISTS "${RTEMS_GXX}")
#	message(FATAL_ERROR 
#		"RTEMS as compiler not found at " 
#		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-as")
#endif()

#message(STATUS "Checking for RTEMS linker..")
#set(RTEMS_LINKER "${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-ld")
#if(NOT EXISTS "${RTEMS_LINKER}")
#	message(FATAL_ERROR 
#		"RTEMS ld linker  not found at "
#		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_VERSION_NAME}-ld")
#endif()

message(STATUS "Checking done")

############################################
# Info output
###########################################

#message(STATUS "RTEMS version: ${RTEMS_VERSION}")
#message(STATUS "RTEMS prefix: ${RTEMS_PREFIX}")
#message(STATUS "RTEMS tools path: ${RTEMS_TOOLS}")
#message(STATUS "RTEMS BSP pair: ${RTEMS_BSP}")
#message(STATUS "RTEMS architecture tools path: "
#	"${RTEMS_PATH}/${RTEMS_ARCH_VERSION_NAME}")
#message(STATUS "RTEMS BSP library path: ${RTEMS_BSP_LIB_PATH}")
#message(STATUS "RTEMS BSP include path: ${RTEMS_BSP_INC_PATH}")
#message(STATUS "RTEMS install target: ${RTEMS_INSTALL}")

#message(STATUS "RTEMS gcc compiler: ${RTEMS_GCC}")
#message(STATUS "RTEMS g++ compiler: ${RTEMS_GXX}")
#message(STATUS "RTEMS assembler: ${RTEMS_ASM}")
#message(STATUS "RTEMS linker: ${RTEMS_LINKER}")

if($ENV{RTEMS_ARCH_NAME} STREQUAL "arm")
    set(CMAKE_SYSTEM_PROCESSOR arm)
elseif ($ENV{RTEMS_ARCH_NAME} STREQUAL "sparc")
	set(CMAKE_SYSTEM_PROCESSOR sparc)
endif()
	
###############################################################################
# Setting variables in upper scope (only the upper scope!)
###############################################################################

set(CMAKE_C_COMPILER ${RTEMS_GCC})
set(CMAKE_CXX_COMPILER ${RTEMS_GXX})
#set(CMAKE_ASM_COMPILER ${RTEMS_ASM})
#set(CMAKE_LINKER ${RTEMS_LINKER})

string (REPLACE ";" " " RTEMS_BSP_CONFIG_CFLAGS "${RTEMS_BSP_CONFIG_CFLAGS}")
string (REPLACE ";" " " RTEMS_BSP_CONFIG_LDFLAGS "${RTEMS_BSP_CONFIG_LDFLAGS}")

set(CMAKE_C_FLAGS ${RTEMS_BSP_CONFIG_CFLAGS})
set(CMAKE_EXE_LINKER_FLAGS ${RTEMS_BSP_CONFIG_CFLAGS} ${RTEMS_BSP_CONFIG_LDFLAGS})

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
