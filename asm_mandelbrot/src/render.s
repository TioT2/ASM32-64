; Render implementation file

%include "src/render_def.s"

section .rodata

; Framebuffer file path
mnd_fb_file_path: db "/dev/fb0", 0x00

section .data

section .text

; Declare render functions
global mnd_render_init
global mnd_render_term
global mnd_render_draw

; Temporary render initialization implementation
extern mnd_render_init_impl

; Render mandelbrot set
; CONV: SYSTEM-V 64
; IN:
;	context - RDI
mnd_render_draw:

.y_loop:

.x_loop:

.x_loop_end:

.y_loop_end:

	ret

; Initialize framebuffer structures
; CONV: SYSTEM-V 64
; IN:
;	context - RDI
; OUT:
;	status (bool) - RAX
mnd_render_init:
	call mnd_render_init_impl ; Call C implementation, lol
	ret

	; open("/dev/fb0", O_RDWR)
	mov rax, LINUX_SYSCALL_OPEN
	mov rdi, mnd_fb_file_path
	mov rsi, LINUX_O_RDWR
	syscall

	cmp eax, -1
	je .fail

	; Save file handle to global variable
	mov [rdi + mnd_render_context.fb_file], eax
	xor rax, rax
	inc rax

	jmp .end
.fail:
	xor rax, rax
.end:
	ret

; Deinitialize framebuffer structures
; CONV: SYSTEM-V 64
; IN:
;	context - RDI
; OUT:
;	status (bool) - RAX
mnd_render_term:
	; Unmap memory
	push rdi
	mov rax, LINUX_SYSCALL_MUNMAP
	mov rdi, [rdi + mnd_render_context.fb_map_ptr]
	syscall
	pop rdi

	; Close file, lol
	push rdi
	mov rax, LINUX_SYSCALL_CLOSE
	mov rdi, [rdi + mnd_render_context.fb_file]
	syscall
	pop rdi
	
	xor rax, rax
	inc rax
	ret
