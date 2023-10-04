# Back-end agnostic metadata
set(CPACK_PACKAGE_VENDOR "Fellowship Inc.")

set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

set(CPACK_COMPONENTS_ALL
	Runtime
	Development
	Documentation
)
set(CPACK_COMPONENT_DEVELOPMENT_DEPENDS Runtime)

set(CPACK_SOURCE_IGNORE_FILES [[/\\.git/;/\\.gitignore;/\\.vscode/;/\\.vs/;/build/;/install/;/package/]])

set(CPACK_PROJECT_CONFIG_FILE "${PROJECT_SOURCE_DIR}/cmake/ProjectOwnerPackageConfig.cmake")

if("DEB" IN_LIST CPACK_GENERATOR)
	include(cmake/ProjectOwnerPackagingDEB.cmake)
endif()

include(CPack)
