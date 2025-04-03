; Mandelbrot set implementation file

%include "src/render_def.s"

section .rodata

; Start function
mnd_str_hassin: db "Hassin!", 0x0A, 0x00
mnd_str_render_init_status: db "Render initialization: %d", 0x0A, 0x00

section .text

; Import exit function
extern mnd_exit
extern mnd_print_fmt
extern mnd_flush

; Import
extern mnd_render_init
extern mnd_render_term

extern mnd_render_draw

; Declare start function
global _start

; Main function
_start:
	push rbp
	mov rbp, rsp
	sub rsp, mnd_render_context_size

	mov rdi, mnd_str_hassin
	call mnd_print_fmt
	call mnd_flush
	
	; Try to initialize render
	mov rdi, rbp+0
	call mnd_render_init
	mov rbx, rax

	; Print status
	mov rdi, mnd_str_render_init_status
	mov rsi, rax
	call mnd_print_fmt
	call mnd_flush

	; Check if status succeeded
	test rbx, rbx
	jz .end

	; Call display function. Just once now.
	mov rdi, rbp+0
	call mnd_render_draw

	; Terminate render
	mov rdi, rbp+0
	call mnd_render_term

.end:
	pop rbp
	; Exit from
	xor rdi, rdi
	call mnd_exit
	ret
