########################################
# Hardware dependent configuration
########################################

# This function performs the hardware dependant RTEMS configuration. It expects
# following arguments:
# 1. Target/executable name
# 2. RTEMS installation prefix, path where the RTEMS toolchain is installed
# 3. RTEMS BSP, which consists generally has the format <Architecture>/<BSP>
function(rtems_hw_config TARGET_NAME RTEMS_INST RTEMS_BSP)

if(RTEMS_BSP STREQUAL "arm/stm32h7")
target_compile_options(${TARGET_NAME} PUBLIC 
	-mthumb
	-mcpu=cortex-m7
	-mfpu=fpv5-d16
	-mfloat-abi=hard
)

target_link_options(${TARGET_NAME} BEFORE PUBLIC 
	-mthumb
	-mcpu=cortex-m7
	-mfpu=fpv5-d16
	-mfloat-abi=hard
)

target_link_options(${TARGET_NAME} PUBLIC
	-Wl,--gc-sections
	-Wl,-Bstatic
	-Wl,-Bdynamic
	-qrtems
)

endif()
endfunction()