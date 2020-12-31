function(rtems_post_project_config TARGET_NAME)

if(RTEMS_VERBOSE)
	message(STATUS "########################################################")
	message(STATUS "# RTEMS tools configuration")
	message(STATUS "########################################################")
	message(STATUS "RTEMS version: ${RTEMS_VERSION}")
	message(STATUS "RTEMS prefix: ${RTEMS_PREFIX}")
	message(STATUS "RTEMS tools path: ${RTEMS_TOOLS}")
	message(STATUS "RTEMS BSP pair: ${RTEMS_BSP}")
	message(STATUS "RTEMS architecture tools path: "
		"${RTEMS_PATH}/${RTEMS_ARCH_VERSION_NAME}"
	)
	message(STATUS "RTEMS BSP library path: ${RTEMS_BSP_LIB_PATH}")
	message(STATUS "RTEMS BSP include path: ${RTEMS_BSP_INC_PATH}")
	message(STATUS "RTEMS install target: ${RTEMS_INSTALL}")

	message(STATUS "RTEMS gcc compiler: ${CMAKE_C_COMPILER}")
	message(STATUS "RTEMS g++ compiler: ${CMAKE_CXX_COMPILER}")
	message(STATUS "RTEMS assembler: ${CMAKE_ASM_COMPILER}")
	message(STATUS "RTEMS linker: ${CMAKE_LINKER}")
	message(STATUS "RTEMS nm: ${CMAKE_NM}")
	message(STATUS "RTEMS ar: ${CMAKE_AR}")
	message(STATUS "########################################################")
endif()

endfunction()
