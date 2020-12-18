########################################
# Hardware dependent configuration
########################################

# This function performs the hardware dependant RTEMS configuration. It expects
# following arguments:
# 1. Target/executable name
# 2. RTEMS installation prefix, path where the RTEMS toolchain is installed
# 3. RTEMS BSP, which consists generally has the format <Architecture>/<BSP>
#
# The following paths should have been set and cached previously:
#
# 1. RTEMS_TOOLS: Path for the RTEMS tools
# 2. RTEMS_PATH: Path for the RTEMS BSPs
# 3. RTEMS_ARCH_LIB_PATH: Library path for the architecture
# 4. RTEMS_BSP_LIB_PATH: Library path for the BSP
# 5. RTEMS_BSP_INC_PATH: Include path for the BSP
# 
# Following variables change the behaviour of this function
#
# 1. RTEMS_SCAN_PKG_CONFIG: Default to TRUE (1). Attempt to scan pkg-config
#    file to determine compiler and linker flags.
# 2. RTEMS_VERBOSE: Default to FALSE (0) .
#    Verbose debug output for the CMake handling.
#
# TODO: Maybe CMake can read the pkgconfig .pc files automatically?

function(rtems_hw_config TARGET_NAME RTEMS_PREFIX RTEMS_BSP)

option(RTEMS_SCAN_PKG_CONFIG 
	"Attempt to scan PKG config file for compiler and linker flags" TRUE
)

if(${RTEMS_SCAN_PKG_CONFIG})

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
	
else()

	set(RTEMS_BSP_CONFIG_FOUND FALSE)

endif()

# Set flags from PKG files
if(${RTEMS_BSP_CONFIG_FOUND})
	message(STATUS "Configuring build flags from pkgconfig file..")

	target_compile_options(${TARGET_NAME} PUBLIC
		${RTEMS_BSP_CONFIG_CFLAGS}
	)

	target_link_options(${TARGET_NAME} PUBLIC
		${RTEMS_BSP_CONFIG_CFLAGS}
		${RTEMS_BSP_CONFIG_LDFLAGS}
	)

# TODO: Maybe remove this section or export to separate file?
else()
	message(STATUS "Configuring build flags manually..")

	# Set flags manually
	if(RTEMS_BSP STREQUAL "arm/stm32h7")

		set(ABI_FLAGS 
			-mthumb 
			-mcpu=cortex-m7 
			-mfpu=fpv5-d16
			-mfloat-abi=hard
		)
	
		target_compile_options(${TARGET_NAME} PUBLIC 
			"${ABI_FLAGS}"
		)
	
		target_include_directories(${TARGET_NAME} PUBLIC
			${RTEMS_BSP_INC_PATH}
		)
	
		target_link_options(${TARGET_NAME} BEFORE PUBLIC 
			"${ABI_FLAGS}"
		)
	
		target_link_options(${TARGET_NAME} PUBLIC
			-Wl,--gc-sections
			-Wl,-Bstatic
			-Wl,-Bdynamic
			-qrtems
			-B${RTEMS_BSP_LIB_PATH}
		)

	elseif(RTEMS_BSP STREQUAL "sparc/erc32")

		# The options for RSB builds and RTEMS source build are different.. 
		# This one is for the RSB build
		if(EXISTS "${RTEMS_BSP_LIB_PATH}/bsp_specs")

			target_compile_options(${TARGET_NAME} PUBLIC
				-qrtems
				-B${RTEMS_ARCH_LIB_PATH}
				-B${RTEMS_BSP_LIB_PATH}
				--specs bsp_specs
				-mcpu=cypress
				-ffunction-sections
				-fdata-sections
			)
	
			target_link_options(${TARGET_NAME} PUBLIC
				-B${RTEMS_ARCH_LIB_PATH}
				-B${RTEMS_BSP_LIB_PATH}
				-qrtems
				--specs bsp_specs
				-Wl,--gc-sections
				-Wl,-Bstatic
				-Wl,-Bdynamic
			)

		else()

			target_compile_options(${TARGET_NAME} PUBLIC 
				-mcpu=cypress
			)
	
			target_include_directories(${TARGET_NAME} PUBLIC
				${RTEMS_BSP_INC_PATH}
			)
	
			target_link_options(${TARGET_NAME} PUBLIC
				-qrtems
				-B${RTEMS_BSP_LIB_PATH}
				-Wl,--gc-sections
			)

		endif()

	else()

		status(WARNING 
			"The pkgconfig for this BSP still needs to be set up"
			"transferred to RTEMSHardware.cmake!"
		)

	endif()

endif()

endfunction()

