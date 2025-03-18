; Hello world example

section .data

; Output buffer
%define ql_out_buffer_len 256
ql_out_buffer: times ql_out_buffer_len db 0
ql_out_buffer_current_len: dq 0

; Number formatting buffer
ql_number_print_buffer: times 65 db 0

; a b c d e f g h i j k l m n o p q r s t u v w x y z
;   - - -                     -       -         -    

; Jump table. Maybe it's a bit..overweight.
ql_print_fmt__jump_table: ; b..x values
	dq ql_print_int_base2  ; b
	dq ql_print_char       ; c
	dq ql_print_int_base10 ; d
	dq ql_empty_function
	dq ql_empty_function
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
ql_print_char:
	; bl - char to print - lower byte of RDI register.
	mov r8, [ql_out_buffer_current_len]

	; Flush output buffer if it's filled
	cmp r8, ql_out_buffer_len
	jb .no_flush
	call ql_flush
.no_flush:
	mov [r8 + ql_out_buffer], dil
	inc dword [ql_out_buffer_current_len]
	ret

; Print binary integer
; CONV: SYSTEM-V 64
; IN:
;	number to print - RDI
ql_print_int_base2:
	mov rax, rdi
	mov rdi, ql_number_print_buffer + 64

	test rax, rax
	jnz .continue

	; handle zero case
	dec rdi
	mov rdi, 30h
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
ql_print_int_base8:
	mov rax, rdi
	mov rdi, ql_number_print_buffer + 64

	test rax, rax
	jnz .continue

	; handle zero case
	dec rdi
	mov rdi, 30h
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
ql_print_int_base10:
	xor rdx, rdx

	push rdi

	mov rax, rdi
	mov rdi, ql_number_print_buffer + 64

	test rax, rax
	jnz .nonzero

	dec rdi
	mov byte [rdi], 0x30
	jmp .end

.nonzero:

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

	pop rax
	cmp rax, 0
	jge .end

	; Write '-' character
	dec rdi
	mov byte [rdi], 0x2D

.end:
	; Print string in r10
	call ql_print_str
	ret

; Print binary integer
; CONV: SYSTEM-V 64
; IN:
;	number to print - RDI
ql_print_int_base16:
	mov rax, rdi
	mov rdi, ql_number_print_buffer + 64

	test rax, rax
	jnz .continue

	; handle zero case
	dec rdi
	mov rdi, 30h
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

; Print strnig
; CONV: SYSTEM-V 64
; IN:
;	string to print (null-terminated) - RDI
;
; TODO: REWRITE THIS SH*T
ql_print_str:
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

; My formatted print function
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

	; R10 - string pointer
	mov r10, rdi

	; R11 - current argument pointer
	mov r11, rsp
	add r11, 8

.main_loop:
	; AL = *RDI
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

	; Print character
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
	cmp al, 25h
	je .print_char

	; Test for validness to be used with jump table
	cmp al, 62h
	jb .main_loop
	cmp al, 78h
	ja .main_loop

	; Load next argument into rcx
	add r11, 8
	mov rdi, [r11]

	; Use jump table!
	call [rax * 8 + ql_print_fmt__jump_table - 62h * 8]
	jmp .main_loop

.end:

	; Restore stack
	pop rax
	pop rsp
	push rax

	ret
