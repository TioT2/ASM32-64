/**
 * Minimal 'standard' library header.
 */

#ifndef QL_H_
#define QL_H_

/// Size type (64-bit integer)
typedef unsigned long long ql_usize;

/**
 * @brief exit from program with certain status
 *
 * @param[in] status status to exit from program with
 *
 * @note this function does not returns
 */
extern void ql_exit( int status );

/**
 * @brief flush buffered output (e.g. ql_print_... function family execution results) buffer on screen
 */
extern void ql_flush( void );

/**
 * @brief calculate string length
 *
 * @param[in] str string to calculate length of (non-null, null-terminated)
 *
 * @return string length
 */
extern ql_usize ql_str_length( const char *str );

/**
 * @brief print certain character to stdout
 *
 * @param[in] ch character to print
 */
extern void ql_print_char( char ch );

/**
 * @brief print string
 *
 * @param[in] str strnig to print (non-null, null-terminated)
 */
extern void ql_print_str( const char *str );

/**
 * @brief formatted print
 * 
 * @param[in] str format string (non-null, null-terminated)
 * @param ... set of format parameters.
 *
 * @note value - '%<ch>'. <ch> valid values:
 * '%': '%' character
 * 'd': signed 64bit integer as decimal
 * 'o': unsigned 64bit integer as octal
 * 'x': unsigned 64bit integer as hexadecimal
 * 'b': unsigned 64bit integer as base 2
 * 'c': ASCII character
 * 'f': 64bit float-point number
 *
 * @note invalid '%<ch>' sequences are ignored
 */
extern void ql_print_fmt( const char *str, ... );

/**
 * @brief print base2 integer
 *
 * @param[in] number number to print
 */
extern void ql_print_int_base2( int number );

/**
 * @brief print octal integer
 *
 * @param[in] number number to print
 */
extern void ql_print_int_base8( int number );

/**
 * @brief print decimal integer
 *
 * @param[in] number number to print
 */
extern void ql_print_int_base10( int number );

/**
 * @brief print hexadecimal integer
 *
 * @param[in] number number to print
 */
extern void ql_print_int_base16( int number );

#endif // !defined(QL_H_)

// ql.h
