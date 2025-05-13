/**
 * @brief main program file
 */

#include "ql.h"

int main( void ) {
	// newline!
	ql_print_str("\nnewline test!\n");

	// Text string
	const char *text = "Hello";

	// Test zero output
	ql_print_fmt("%bb %oo %dd %xx\n", 0ll, 0ll, 0ll, 0ll);

	// String, decimal, hexadecimal and binary test
	ql_print_fmt("%s!!! %d!!! 0x%x. %b.\n", text, -42ll, 0xDEADBEEFll, 0xFFFFFFFFFFFFFFFFll);

	// Octal, percent and character test
	ql_print_fmt("%o%% %c\n", 8ll, 'q');

	// Test floating point overflow
	ql_print_fmt("%f %f %f %f %f %f %f %f %f %f\n", 0.42, -571.0312, 22222222.02, 4.0, 5.0, 5.0, 5.0, 5.0, 4.0, 7.0);

	// Print buffer
	char buffer[1024] = {0};
	for (ql_usize i = 0; i < sizeof(buffer) - 1; i++)
		buffer[i] = 'U';
	ql_print_str(buffer);

	// Flush output buffer
	ql_flush();

	// Print characters in sequence (to test buffer overflow)
	for (int i = 0; i < 512; i++)
		ql_print_char(i % (int)('z' - 'a' + 1) + 'a');
	ql_flush();

	// Exit
	return 0;
} // main

// main.c
