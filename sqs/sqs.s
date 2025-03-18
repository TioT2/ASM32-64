; Hello world example

section .data
S_Input: db `Input quadratic equation coefficents:\n\0`
S_CoefA: db `\tA: \0`
S_CoefB: db `\tB: \0`
S_CoefC: db `\tC: \0`
S_ScanfFormat: db `\%f\0`

section .text
global main

extern printf
extern scanf
extern exit

; Start function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 8


	mov rdi, S_Input
	call printf

	mov rdi, S_CoefA
	call printf

	mov rdi, S_ScanfFormat
	mov rsi, rbp
	call scanf

	mov rdi, S_ScanfFormat
	mov rsi, [rsi]
	call printf

	mov rdi, S_CoefB
	call printf

	mov rdi, S_CoefC
	call printf

	add rsp, 8
	pop rbp

	mov rdi, 0
	call exit
	mov rax, 0
	ret
