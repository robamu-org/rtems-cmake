function(rtems_pkg_config)

message(STATUS "Trying to load PkgConfig module..")
find_package(PkgConfig)

set(RTEMS_PKG_MODULE_NAME "${RTEMS_ARCH_VERSION_NAME}-${RTEMS_BSP_NAME}")
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

if(RTEMS_VERBOSE)
	message(STATUS "########################################################")
	message(STATUS "# PKG Configuration")
	message(STATUS "########################################################")
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
	message(STATUS "########################################################")
endif()

endfunction()