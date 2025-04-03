; Render definitions

; Linux systemcall definitions
%define LINUX_SYSCALL_OPEN   0x02
%define LINUX_SYSCALL_CLOSE  0x06
%define LINUX_SYSCALL_MMAP   0x09
%define LINUX_SYSCALL_MUNMAP 0x0B
%define LINUX_SYSCALL_EXIT   0x3C

; Linux read-write
%define LINUX_O_RDWR 2

; Render context structure
struc mnd_render_context
    .fb_map_ptr resq 1
    .fb_file    resw 1
    .stride     resw 1
    .width      resw 1
    .height     resw 1
    .data       resq 1
endstruc
