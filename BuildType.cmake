function(set_build_type)

message(STATUS "Used build generator: ${CMAKE_GENERATOR}")

# Set a default build type if none was specified
set(DEFAULT_BUILD_TYPE "RelWithDebInfo")
if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
	set(DEFAULT_BUILD_TYPE "Debug")
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS 
		"Setting build type to '${DEFAULT_BUILD_TYPE}' as none was specified."
	)
	set(CMAKE_BUILD_TYPE "${DEFAULT_BUILD_TYPE}" CACHE
		STRING "Choose the type of build." FORCE
	)
	# Set the possible values of build type for cmake-gui
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
		"Debug" "Release" "MinSizeRel" "RelWithDebInfo"
	)
endif()

if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
	message(STATUS 
		"Building Debug application with flags: ${CMAKE_C_FLAGS_DEBUG}"
	)
elseif(${CMAKE_BUILD_TYPE} MATCHES "RelWithDebInfo")
	message(STATUS 
		"Building Release (Debug) application with "
		"flags: ${CMAKE_C_FLAGS_RELWITHDEBINFO}"
	)
elseif(${CMAKE_BUILD_TYPE} MATCHES "MinSizeRel")
	message(STATUS 
		"Building Release (Size) application with "
		"flags: ${CMAKE_C_FLAGS_MINSIZEREL}"
	)
else()
	message(STATUS 
		"Building Release (Speed) application with "
		"flags: ${CMAKE_C_FLAGS_RELEASE}"
	)
endif()

endfunction()
