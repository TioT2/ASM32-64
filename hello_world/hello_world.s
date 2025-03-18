; Hello world example

section .data
String: db "Hello world!"

section .text
global _start

; Start function
_start:

	; Call
	mov rax, 1
	mov rdi, 1
	mov rsi, String
	mov rdx, 12
	syscall

	mov rax, 60
	mov rdi, 0
	syscall
