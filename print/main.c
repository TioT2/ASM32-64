/// Main program function

#include "ql.h"

/**
 * @brief Main program function (C STDLIB initialization is disabled, so I must use _start as entry point)
 */
void _start( void ) {
	// newline!
	ql_print_str("\nnewline test!\n");

	// Text string
	const char *text = "Hello";

	ql_print_fmt("%d!!!\n", 0);

	// String, decimal, hexadecimal and binary test
	ql_print_fmt("%s!!! %d!!! 0x%x. %b.\n", text, -42ll, 0xDEADBEEFll, 0xFFFFFFFFFFFFFFFFll);

	// Octal, percent and character test
	ql_print_fmt("%o%% %c\n", 8ll, 'q');

	// Floating point overflow test
	ql_print_fmt("%f %f %f %f %f %f %f %f %f %f\n", 3.0, 1.0, 2.0, 4.0, 5.0, 5.0, 5.0, 5.0, 4.0, 7.0);

	// Flush output buffer
	ql_flush();

	// Exit from program with success status
	ql_exit(0);

	// Print characters in sequence (to test overflow)
	for (int i = 0; i < 512; i++)
		ql_print_char(i % (int)('z' - 'a' + 1) + 'a');
} // _start

// main.c
