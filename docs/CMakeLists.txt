set(INPUT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/index.md.in")
set(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/markdown")
set(OUTPUT_FILE "${OUTPUT_DIR}/index.md")

add_custom_command(
	OUTPUT "${OUTPUT_FILE}"
	DEPENDS "${INPUT_FILE}"
	COMMAND "${CMAKE_COMMAND}"
	ARGS
		-D "PROJECT_VERSION=${PROJECT_VERSION}"
		-D "OUTPUT=${OUTPUT_FILE}"
		-D "INPUT=${INPUT_FILE}"
		-P "${PROJECT_SOURCE_DIR}/cmake/SphinxInDisguise.cmake"
	COMMENT "Generating doc/index.md"
)

add_custom_target(doc
	ALL
	DEPENDS "${OUTPUT_FILE}"
)

install(
	DIRECTORY "${OUTPUT_DIR}"
	TYPE DOC
	COMPONENT Documentation
)