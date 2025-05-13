; Hello world example

section .data

; Output buffer length
%define ql_out_buffer_len 512

; Buffer contents
ql_out_buffer: times ql_out_buffer_len db 0

; Buffer end pointer
ql_out_buffer_end:

; Current buffer length (< ql_out_buffer_len)
ql_out_buffer_current_len: dq 0

; Length of number print buffer
%define ql_number_print_buffer_len 128

; Number formatting buffer
ql_number_print_buffer: times ql_number_print_buffer_len db 0

; a b c d e f g h i j k l m n o p q r s t u v w x y z
;   - - -                     -       -         -    

; Jump table. Maybe it's a bit..overweight.
ql_print_fmt__jump_table: ; b..x values
	dq ql_print_int_base2  ; b
	dq ql_print_char       ; c
	dq ql_print_int_base10 ; d
	dq ql_empty_function
	dq ql_print_float      ; f
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_print_int_base8  ; o
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_print_str        ; s
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_empty_function
	dq ql_print_int_base16 ; x

; Load floating-point arguments from xmm registers.
ql_print_fmt_next_float__jump_table:
	dq ql_print_fmt_next_float.from_xmm0
	dq ql_print_fmt_next_float.from_xmm1
	dq ql_print_fmt_next_float.from_xmm2
	dq ql_print_fmt_next_float.from_xmm3
	dq ql_print_fmt_next_float.from_xmm4
	dq ql_print_fmt_next_float.from_xmm5
	dq ql_print_fmt_next_float.from_xmm6
	dq ql_print_fmt_next_float.from_xmm7

section .text

; Expose library functions
global ql_str_length
global ql_flush
global ql_print_char
global ql_print_fmt
global ql_print_str
global ql_exit
global ql_print_int_base2
global ql_print_int_base8
global ql_print_int_base10
global ql_print_int_base16

; Exit from program
; CONV: SYSTEM-V 64
; IN:
;	exit code: RDI
ql_exit:
	mov rax, 60
	syscall
	ret

; Does nothing
ql_empty_function:
	ret

; Flush output buffer
; CONV: SYSTEM-V 64
; USES:
;	RAX (= 0)
;	RDI (= 1)
;	RSI (= ql_out_buffer)
;	RDX (= *ql_out_buffer_current_len)
ql_flush:
	mov rax, [ql_out_buffer_current_len]

	; Omit empty flush)
	test rax, rax
	jz .end

	; Display out buffer
	mov rax, 1
	mov rdi, 1
	mov rsi, ql_out_buffer
	mov rdx, [ql_out_buffer_current_len]
	syscall

	; Clear out buffer
	xor rax, rax
	mov [ql_out_buffer_current_len], rax

.end:
	ret

; Calculate string length
; CONV: SYSTEM-V 64
; IN:
;	string ptr - RDI
; OUT:
;	RAX (= string length)
; USES:
;	RSI (= 0)
;	RDI (= _RDI)
ql_str_length:
	mov rax, rdi

.continue:
	inc rdi
	mov sil, [rdi]
	test sil, sil
	jnz .continue

	xchg rdi, rax
	sub rax, rdi
	ret

; My putchar function
; CONV: SYSTEM-V 64
; IN:
;	character to print - DIL
; USES:
;	R8
;	DIL
ql_print_char:
	; bl - char to print - lower byte of RDI register.
	mov r8, [ql_out_buffer_current_len]

	; Flush output buffer if it's filled
	cmp r8, ql_out_buffer_len
	jb .no_flush

	; It's very infrequent, so it's ok to do this here
	push rax
	push rsi
	push rdx
	call ql_flush
	pop rdx
	pop rsi
	pop rax

.no_flush:
	mov [r8 + ql_out_buffer], dil
	inc dword [ql_out_buffer_current_len]
	ret

; Print binary integer
; CONV: SYSTEM-V 64
; IN:
;	number to print - RDI
; USES:
;	RAX
;	RDI
;	RSI
;	R8
ql_print_int_base2:
	mov rax, rdi
	mov rdi, ql_number_print_buffer + ql_number_print_buffer_len - 1

	test rax, rax
	jnz .continue

	; handle zero case
	dec rdi
	mov byte [rdi], 30h
	jmp .end

.continue:
	mov rsi, rax
	and rsi, 1
	add rsi, 30h

	dec rdi
	mov [rdi], sil

	shr rax, 1

	test rax, rax
	jnz .continue

.end:
	call ql_print_str
	ret

; Print binary integer
; CONV: SYSTEM-V 64
; IN:
;	number to print - RDI
; USES:
;	RAX
;	RDI
;	RSI
;	R8
ql_print_int_base8:
	mov rax, rdi
	mov rdi, ql_number_print_buffer + ql_number_print_buffer_len - 1

	test rax, rax
	jnz .continue

	; handle zero case
	dec rdi
	mov byte [rdi], 30h
	jmp .end

.continue:
	mov rsi, rax
	and rsi, 7
	add rsi, 30h

	dec rdi
	mov [rdi], sil

	shr rax, 3

	test rax, rax
	jnz .continue

.end:
	call ql_print_str
	ret

; Print binary integer
; CONV: SYSTEM-V 64
; IN:
;	number to print - RDI
; USES:
;	RAX
;	RDX
;	RDI
;	RSI
;	R8
ql_print_int_base10:
	xor rdx, rdx

	mov rax, rdi
	mov rdi, ql_number_print_buffer + ql_number_print_buffer_len - 1

	test rax, rax
	jnz .nonzero

	; Write '0' character and exit
	dec rdi
	mov byte [rdi], 0x30
	jmp .end

.nonzero:

	; Save RAX to decide if '-' character is needed
	push rax

	; Negate rax if it is negative
	cmp rax, 0
	jg .continue
	neg rax

.continue:
	mov r8, 0xA

	mov rsi, rax
	idiv r8
	imul r8
	sub rsi, rax
	idiv r8

	add rsi, 0x30

	dec rdi
	mov [rdi], sil

.test:
	test rax, rax
	jnz .continue

	; Load RDI to write '-' character
	pop rax
	cmp rax, 0
	jge .end

	; Write '-' character
	dec rdi
	mov byte [rdi], 0x2D

.end:
	; Print string
	call ql_print_str
	ret

; Print binary integer
; CONV: SYSTEM-V 64
; IN:
;	number to print - RDI
; USES:
;	RAX
;	RDI
;	RSI
;	R8
ql_print_int_base16:
	mov rax, rdi
	mov rdi, ql_number_print_buffer + ql_number_print_buffer_len - 1

	test rax, rax
	jnz .continue

	; handle zero case
	dec rdi
	mov byte [rdi], 30h
	jmp .end

.continue:
	mov rsi, rax

	; Perform bit more clever
	and rsi, 0xF

	cmp rsi, 0xA
	jl .number
	add rsi, 0x7
.number:
	add rsi, 30h

	dec rdi
	mov [rdi], sil

	shr rax, 4
	test rax, rax
	jnz .continue

.end:
	call ql_print_str
	ret

; Print float (alias to ql_print_int_base16 now)
; IN:
;	number to print - rdi
; TODO:
;	BUILD ACTUAL FLOAT PRINTING FUNCTION
ql_print_float:
	movq xmm0, rdi
	call ql_print_int_base16
	ret

; Print string (new new implementation)
; CONV: SYSTEM-V 64
; IN:
;	string to print (null-terminated) - RDI
; USES:
;	RSI
;	RDI
;	RAX
;	RDX
ql_print_str:
	; Calculate string length
	call ql_str_length

	; Get out buffer rest count
	mov rsi, ql_out_buffer_len * 2
	sub rsi, [ql_out_buffer_current_len]

	; Check if string is TOO long
	cmp rax, rsi
	jae .very_long_str

	; rsi = out_buffer_len - out_buffer_current_len
	sub rsi, ql_out_buffer_len

	; Test if the string can be fully written to out buffer
	cmp rax, rsi
	jae .long_str

.short_str:
	mov rsi, ql_out_buffer
	add rsi, [ql_out_buffer_current_len]
	add [ql_out_buffer_current_len], rax

.short_loop_start:
	mov dl, [rdi]
	inc rdi
	mov [rsi], dl
	inc rsi

.short_test:
	dec rax
	jnz .short_loop_start

	ret

.long_str: ; Write start, flush, write rest
	mov rsi, ql_out_buffer
	add rsi, [ql_out_buffer_current_len]

	; Fill out buffer
.long_loop_start:
	mov dl, [rdi]
	inc rdi
	mov [rsi], dl
	inc rsi

.long_test:
	cmp rsi, ql_out_buffer_end
	jb .long_loop_start

	; Compute rest length
	add rax, ql_out_buffer_len
	sub rax, [ql_out_buffer_current_len]

	; Write current len
	mov qword [ql_out_buffer_current_len], ql_out_buffer_len

	; Flush
	push rax
	push rdi
	call ql_flush
	pop rdi
	pop rax

	; Write rest
.long_end_start:
	mov dl, [rdi]
	inc rdi
	mov [rsi], dl
	inc rsi
.long_end_test:
	dec rax
	jnz .long_end_start

	; Exit
	ret

.very_long_str: ; Flush, write by systemcall

	; Flush string buffer
	push rax
	push rdi
	call ql_flush
	pop rdi
	pop rax

	; Write string by systemcall
	mov rdx, rax ; Buffer length
	mov rsi, rdi ; Buffer pointer
	mov rdi, 1   ; File descriptor
	mov rax, 1   ; Systemcall index
	syscall

	ret

; Print strnig
; CONV: SYSTEM-V 64
; IN:
;	string to print (null-terminated) - RDI
; USES:
;	RSI
;	RDI
;	R8
;	RAX
;	RDX
; TODO:
;	REWRITE THIS SH*T
ql_print_str_old:
	; RAX = string length
	call ql_str_length

	mov rsi, rdi
	jmp .test

.continue:
	call ql_print_char
.test:
	mov dil, [rsi]
	inc rsi
	test dil, dil
	jnz .continue

	ret

; Get next float-point parameter
; IN:
;	float index - R9
; OUT:
;	float value - RDI
ql_print_fmt_next_float:
	cmp r9, 8
	jge .from_stack

	jmp [r9 * 8 + ql_print_fmt_next_float__jump_table]
.from_xmm0:
	movq rdi, xmm0
	jmp .end
.from_xmm1:
	movq rdi, xmm1
	jmp .end
.from_xmm2:
	movq rdi, xmm2
	jmp .end
.from_xmm3:
	movq rdi, xmm3
	jmp .end
.from_xmm4:
	movq rdi, xmm4
	jmp .end
.from_xmm5:
	movq rdi, xmm5
	jmp .end
.from_xmm6:
	movq rdi, xmm6
	jmp .end
.from_xmm7:
	movq rdi, xmm7
	jmp .end

.from_stack:
	shl r9, 3
	mov rdi, rsp
	add rdi, r9
	shr r9, 3
	; load froms tack
	mov rdi, [rdi]
	
.end:

	ret

; My formatted print function
; CONV: SYSTEM-V
; IN:
;	format string - rdi
; USES:
;	...
ql_print_fmt:
	; Save stack value
	mov r10, rsp

	; Load return pointer from stack
	pop rax

	; Write registers to stack
	push r9
	push r8
	push rcx
	push rdx
	push rsi

	; Save return pointer and initial stack address
	push r10
	push rax

	; R9 - float point index
	xor r9, r9

	; R10 - string pointer
	mov r10, rdi

	; R11 - current argument pointer
	mov r11, rsp
	add r11, 8

.main_loop:
	; AL = *R10
	mov al, [r10]
	inc r10

	; Test for stirng end
	test al, al
	jz .end

	; Go to '%' handler.
	cmp al, 25h
	je .handle_fmt

.print_char:

	; Further optimization?
	mov dil, al
	call ql_print_char

	; Continue
	jmp .main_loop

.handle_fmt:

	; %c, %s, %d, %x, %o, %b, %%
	; a b c d e f g h i j k l m n o p q r s t u v w x y z
	;   - - -                     -       -         -    
	; b..x jump table

	; Load character into RAX
	xor rax, rax
	mov al, [r10]
	inc r10

	; Test for lack of next character
	test al, al
	jz .end

	; Test for "%%" combination
	cmp al, 0x25
	je .print_char

	; Check for jump table usability
	cmp al, 0x62
	jb .main_loop
	cmp al, 0x78
	ja .main_loop

	cmp al, 0x66
	jne .load_arg_stack

	; Load next float
	call ql_print_fmt_next_float
	inc r9

	jmp .call

.load_arg_stack:
	; Load next argument into rcx
	add r11, 8
	mov rdi, [r11]
.call:

	; Use jump table!
	call [rax * 8 + ql_print_fmt__jump_table - 62h * 8]
	jmp .main_loop

.end:

	; Restore stack
	pop rax
	pop rsp
	push rax

	ret
