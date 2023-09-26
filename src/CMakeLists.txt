set(LIB_NAME Useful)

if(USEFUL_BUILD_SHARED_LIBS)
	add_library(${LIB_NAME} SHARED)
else()
	add_library(${LIB_NAME} STATIC)
endif()

string(TOUPPER ${LIB_NAME} UPPER_LIB_NAME)
generate_export_header(${LIB_NAME}
	EXPORT_MACRO_NAME ${UPPER_LIB_NAME}_EXPORT
	EXPORT_FILE_NAME ${LIB_NAME}_Export.hpp
)
target_sources(${LIB_NAME}
	PRIVATE Useful.cpp
)
target_sources(${LIB_NAME}
	PUBLIC
		FILE_SET public_header_files
			TYPE HEADERS
			BASE_DIRS
				"${PROJECT_SOURCE_DIR}/include"
				"${CMAKE_CURRENT_BINARY_DIR}"
			FILES
				"${CMAKE_CURRENT_BINARY_DIR}/${LIB_NAME}_Export.hpp"
				"${PROJECT_SOURCE_DIR}/include/Useful.hpp"
	PRIVATE
		FILE_SET private_header_files
			TYPE HEADERS
			BASE_DIRS "${PROJECT_SOURCE_DIR}/src"
			FILES DefaultLocale.hpp
)
target_include_directories(${LIB_NAME}
	PUBLIC
		$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
		$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)
install(
	TARGETS ${LIB_NAME}
	RUNTIME
		DESTINATION ${CMAKE_INSTALL_BINDIR}
		COMPONENT Runtime
	LIBRARY
		DESTINATION ${CMAKE_INSTALL_LIBDIR}
		NAMELINK_SKIP
		COMPONENT Runtime
	ARCHIVE
		DESTINATION ${CMAKE_INSTALL_LIBDIR}
		COMPONENT Runtime
)
install(
	TARGETS ${LIB_NAME}
	EXPORT ${LIB_NAME}Exports
	LIBRARY
		DESTINATION ${CMAKE_INSTALL_LIBDIR}
		NAMELINK_ONLY
		COMPONENT Development
	PUBLIC_HEADER
		DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
		COMPONENT Development
	FILE_SET public_header_files
		DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
		COMPONENT Development
)
install(
# FILES $<TARGET_PDB_FILE:${LIB_NAME}> is cleanest, but is MSVC link.exe specific. LLVM's lld.exe and lld-link.exe don't support it (configure-time error)
# FILES $<TARGET_PROPERTY:${LIB_NAME},COMPILE_PDB_OUTPUT_DIRECTORY>/${LIB_NAME}.pdb looks OK, but even though there's a PDB, this prop is empty on non-MSVC toolchains
  FILES $<TARGET_FILE_DIR:${LIB_NAME}>/${LIB_NAME}.pdb # is the most implicit (expect PDB be next to the library), yet the only one that universally works
  DESTINATION ${CMAKE_INSTALL_BINDIR}
  OPTIONAL
)
set(config_package_location ${CMAKE_INSTALL_DATADIR}/cmake/${LIB_NAME})
install(
	EXPORT ${LIB_NAME}Exports
	FILE ${LIB_NAME}Config.cmake
	NAMESPACE Proj::
	DESTINATION ${config_package_location}
	COMPONENT Development
)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${LIB_NAME}ConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/${LIB_NAME}ConfigVersion.cmake"
  DESTINATION ${config_package_location}
  COMPONENT Development
)
unset(config_package_location)

add_executable(Capitalizer)

target_sources(Capitalizer
	PRIVATE Capitalizer.cpp
)

target_link_libraries(Capitalizer PRIVATE ${LIB_NAME})

install(
	TARGETS Capitalizer
	EXPORT CapitalizerExports
	RUNTIME
		DESTINATION ${CMAKE_INSTALL_BINDIR}
		COMPONENT Runtime
)

