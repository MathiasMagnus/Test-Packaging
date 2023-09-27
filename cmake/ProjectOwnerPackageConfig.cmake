macro(unset_then_force_set)
	message(DEBUG "${ARGV0}: ${${ARGV0}}")
	set("${ARGV0}" "${ARGV1}" CACHE STRING "" FORCE)
	message(DEBUG "${ARGV0}: ${${ARGV0}}")
endmacro()

cmake_path(GET CMAKE_CURRENT_LIST_DIR PARENT_PATH SOURCE_ROOT)

if(CPACK_GENERATOR MATCHES "DEB")
	unset_then_force_set(CPACK_SOURCE_INSTALLED_DIRECTORIES "${SOURCE_ROOT};/usr/src/libuseful")
endif()

if(CPACK_GENERATOR MATCHES "TGZ")
	unset_then_force_set(CPACK_PACKAGING_INSTALL_PREFIX "")
	unset_then_force_set(CPACK_SOURCE_INSTALLED_DIRECTORIES "${SOURCE_ROOT};/")
endif()