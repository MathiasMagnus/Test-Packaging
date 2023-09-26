cmake_minimum_required(VERSION 3.23)
cmake_policy(VERSION 3.23...3.27)
enable_testing()

project(Useful
	VERSION 0.1
	LANGUAGES CXX
)

include(CMakePackageConfigHelpers)
include(CMakeDependentOption)
include(GenerateExportHeader)
include(GNUInstallDirs)

option(USEFUL_BUILD_LIBRARY "Build Useful library" ON)
cmake_dependent_option(USEFUL_BUILD_SHARED_LIBS
	"Build Useful library as SHARED"
	"${BUILD_SHARED_LIBS}"
	USEFUL_BUILD_LIBRARY
	OFF
)
cmake_dependent_option(USEFUL_BUILD_TESTING
	"Build Useful unit tests"
	${PROJECT_IS_TOP_LEVEL}
	USEFUL_BUILD_LIBRARY
	OFF
)
option(USEFUL_BUILD_DOCS "Build Useful documentation" ON)
set(USEFUL_PACKAGING_SCRIPT
	"cmake/ProjectOwnerPackaging.cmake"
	CACHE
	FILEPATH
	"Path to packaging script. (Relative paths should be relative to PROJECT_SOURCE_DIR)"
)

if(USEFUL_BUILD_LIBRARY)
	add_subdirectory(src)
endif()

if(USEFUL_BUILD_TESTING)
	add_subdirectory(tests)
endif()

if(USEFUL_BUILD_DOCS)
	add_subdirectory(docs)
endif()

cmake_path(ABSOLUTE_PATH USEFUL_PACKAGING_SCRIPT
	BASE_DIRECTORY "${PROJECT_SOURCE_DIR}"
	NORMALIZE
	OUTPUT_VARIABLE USEFUL_PACKAGING_SCRIPT
)
if(EXISTS "${USEFUL_PACKAGING_SCRIPT}")
	include("${USEFUL_PACKAGING_SCRIPT}")
endif()
