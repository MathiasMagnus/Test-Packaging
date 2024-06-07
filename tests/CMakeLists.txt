foreach(TEST_STRING
	"something"
	"AnyThing"
	"ALLCAPS"
	#"$p€chi@ł_characters"
)
	string(TOUPPER "${TEST_STRING}" UPPERCASE_TEST_STRING)
	add_test(
		NAME "${TEST_STRING}"
		COMMAND Capitalizer "${TEST_STRING}"
	)
	set_tests_properties("${TEST_STRING}"
		PROPERTIES
			PASS_REGULAR_EXPRESSION "${UPPERCASE_TEST_STRING}"
			LABELS "Basic"
	)
endforeach()