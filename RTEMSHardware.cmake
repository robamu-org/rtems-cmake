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
# 1. RTEMS_ARCH_LIB_PATH: Library path for the architecture
# 2. RTEMS_BSP_LIB_PATH: Library path for the BSP
# 3. RTEMS_BSP_INC_PATH: Include path for the BSP
#
# TODO: Maybe CMake can read the pkgconfig .pc files automatically?

function(rtems_hw_config TARGET_NAME RTEMS_PREFIX RTEMS_BSP)

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

endfunction()

