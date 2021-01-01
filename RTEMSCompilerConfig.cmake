function(rtems_compiler_config RTEMS_PREFIX RTEMS_BSP)

message(STATUS "Setting up and checking RTEMS cross compile configuration..")

set(RTEMS_PREFIX ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS prefix")
set(RTEMS_BSP ${RTEMS_BSP} CACHE STRING "RTEMS BSP")

if(NOT DEFINED RTEMS_VERSION) 
	if(NOT DEFINED ENV{RTEMS_VERSION})
		message(WARNING 
			"No RTEMS verson specified via argument or in"
			" environment variables!"
		)
	else()
		set(RTEMS_VERSION $ENV{RTEMS_VERSION})
		set(RTEMS_VERSION ${RTEMS_VERSION} CACHE STRING "RTEMS version")
	endif()
endif()

if(NOT RTEMS_VERSION)
	message(STATUS "No RTEMS_VERSION supplied.")
    message(STATUS "Autodetermining version from tools path ${RTEMS_TOOLS} ..")
    string(REGEX MATCH [0-9]+$ RTEMS_VERSION "${RTEMS_TOOLS}")
    message(STATUS "Version ${RTEMS_VERSION} found")
	set(RTEMS_VERSION ${RTEMS_VERSION} CACHE STRING "RTEMS version")
endif()

set(RTEMS_INSTALL 
	${CMAKE_INSTALL_PREFIX} 
	CACHE FILEPATH "RTEMS install destination"
)

if(NOT RTEMS)
	if(NOT $ENV{RTEMS})
		message(STATUS 
			"RTEMS path was not specified and was set to RTEMS prefix."
		)
	else()
		set(RTEMS $ENV{RTEMS})
	endif()

	set(RTEMS ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS folder")
endif()

set(RTEMS ${RTEMS} CACHE FILEPATH "RTEMS folder")

if(NOT RTEMS_TOOLS)
	if(NOT $ENV{RTEMS})
		message(STATUS 
			"RTEMS toolchain path was not specified and was set to RTEMS prefix."
		)
	else()
		set(RTEMS_TOOLS $ENV{RTEMS_TOOLS})
	endif()
	
	set(RTEMS_TOOLS ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS tools folder")
endif()



if(NOT ENV{RTEMS_ARCH_VERSION_NAME})
	string(REPLACE "/" ";" RTEMS_BSP_LIST_SEPARATED ${RTEMS_BSP})
	list(LENGTH RTEMS_BSP_LIST_SEPARATED BSP_LIST_SIZE)

	if(NOT ${BSP_LIST_SIZE} EQUAL 2)
    	message(FATAL_ERROR 
    		"Supplied RTEMS_BSP variable invalid. " 
    		"Make sure to provide a slash separated string"
    	)
	endif()

	list(GET RTEMS_BSP_LIST_SEPARATED 0 RTEMS_ARCH_NAME)
	list(GET RTEMS_BSP_LIST_SEPARATED 1 RTEMS_BSP_NAME)

	set(RTEMS_ARCH_VERSION_NAME 
		"${RTEMS_ARCH_NAME}-rtems${RTEMS_VERSION}" 
		CACHE STRING 
		"Architecture-BSP-Version Identifier"
	)
	
endif()

set(RTEMS_ARCH_LIB_PATH "${RTEMS}/${RTEMS_ARCH_VERSION_NAME}/lib")
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

endfunction()