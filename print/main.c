#include "ql.h"
#include <stdio.h>

void call_example( void );

/**
 * @brief Main program function (C STDLIB initialization is disabled, so I must use _start as entry point)
 */
void _start( void ) {
	// newline!
	ql_print_str("\nnewline test!\n");

	const char *text = "Hello";
	// Initial format test.
	ql_print_fmt("%s!!! %d!!! 0x%x. %b.\n", text, (long long)-42, (long long)0xDEADBEEF, (long long)0xFFFFFFFFFFFFFFFF);
	ql_print_fmt("%o%% %c", (long long)8, 'q');

	// Flush output buffer
	ql_flush();

	// Exit from program with success status
	ql_exit(0);

	// Print characters in sequence (to test overflow)
	for (int i = 0; i < 512; i++)
		ql_print_char(i % (int)('z' - 'a' + 1) + 'a');
} // _start

// main.c
