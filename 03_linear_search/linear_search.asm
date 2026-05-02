; ============================================================
; linear_search.asm — x86-64 NASM
; Linear Search: user types a number, program searches array
;
; Build & Run:
;   nasm -f elf64 linear_search.asm -o linear_search.o
;   ld linear_search.o -o linear_search
;   ./linear_search
; ============================================================

section .data
    array       dq  15, 42, 8, 93, 27, 61, 4, 78, 36, 55
    array_len   equ 10

    banner_top  db  "==============================", 10, 0
    banner_bot  db  "==============================", 10, 0
    title       db  "  Linear Search — x86-64 ASM  ", 10, 0

    msg_array   db  "Array : ", 0
    msg_prompt  db  "Search: ", 0
    msg_found   db  "Found at index : ", 0
    msg_notfound db "Not found!", 10, 0
    msg_done    db  10, "Done!", 10, 0

    space       db  " ", 0
    newline     db  10, 0
    bracket_l   db  "[", 0
    bracket_r   db  "]", 0

section .bss
    input_buf   resb 20
    num_buf     resb 20

section .text
    global _start

; ============================================================
; _start
; ============================================================
_start:
    ; --- banner ---
    mov  rsi, banner_top
    call print_str
    mov  rsi, title
    call print_str
    mov  rsi, banner_bot
    call print_str
    mov  rsi, newline
    call print_str

    ; --- print array ---
    mov  rsi, msg_array
    call print_str

    mov  rcx, array_len
    mov  rbx, 0
.print_loop:
    push rcx
    push rbx
    mov  rsi, bracket_l
    call print_str
    mov  rax, [array + rbx*8]
    call print_int
    mov  rsi, bracket_r
    call print_str
    mov  rsi, space
    call print_str
    pop  rbx
    pop  rcx
    inc  rbx
    loop .print_loop

    mov  rsi, newline
    call print_str
    mov  rsi, newline
    call print_str

    ; --- prompt user ---
    mov  rsi, msg_prompt
    call print_str

    ; --- read input ---
    mov  rax, 0                     ; sys_read
    mov  rdi, 0                     ; stdin
    mov  rsi, input_buf
    mov  rdx, 20
    syscall

    ; --- convert input string to integer -> r12 ---
    mov  rsi, input_buf
    call str_to_int
    mov  r12, rax                   ; r12 = target number

    ; --- linear search ---
    mov  r9, 0                      ; index
.search_loop:
    cmp  r9, array_len
    jge  .not_found

    mov  rax, [array + r9*8]
    cmp  rax, r12
    je   .found

    inc  r9
    jmp  .search_loop

.found:
    mov  rsi, newline
    call print_str
    mov  rsi, msg_found
    call print_str
    mov  rax, r9
    call print_int
    mov  rsi, newline
    call print_str
    jmp  .done

.not_found:
    mov  rsi, newline
    call print_str
    mov  rsi, msg_notfound
    call print_str

.done:
    mov  rsi, msg_done
    call print_str

    mov  rax, 60
    xor  rdi, rdi
    syscall

; ============================================================
; str_to_int — convert null/newline-terminated string at rsi
;              returns integer in rax
; ============================================================
str_to_int:
    xor  rax, rax
    xor  rcx, rcx
.next_char:
    movzx rcx, byte [rsi]
    cmp  cl, 10                     ; newline
    je   .done_conv
    cmp  cl, 0
    je   .done_conv
    cmp  cl, '0'
    jl   .done_conv
    cmp  cl, '9'
    jg   .done_conv
    sub  cl, '0'
    imul rax, rax, 10
    add  rax, rcx
    inc  rsi
    jmp  .next_char
.done_conv:
    ret

; ============================================================
; print_int — print signed 64-bit integer in rax
; ============================================================
print_int:
    push rbp
    mov  rbp, rsp
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    lea  rdi, [num_buf + 19]
    mov  byte [rdi], 0
    mov  rbx, 10
    xor  rcx, rcx

    test rax, rax
    jnz  .check_sign
    dec  rdi
    mov  byte [rdi], '0'
    inc  rcx
    jmp  .do_print

.check_sign:
    push rax
    jns  .positive
    neg  rax
    push rax
    dec  rdi
    mov  byte [rdi], '-'
    inc  rcx
    pop  rax
    push rax

.positive:
    pop  rax
    push rax

.digit_loop:
    pop  rax
    test rax, rax
    jz   .do_print
    xor  rdx, rdx
    div  rbx
    push rax
    add  dl, '0'
    dec  rdi
    mov  [rdi], dl
    inc  rcx
    jmp  .digit_loop

.do_print:
    mov  rax, 1
    mov  rsi, rdi
    mov  rdx, rcx
    mov  rdi, 1
    syscall

    pop  rsi
    pop  rdi
    pop  rdx
    pop  rcx
    pop  rbx
    pop  rbp
    ret

; ============================================================
; print_str — print null-terminated string at rsi
; ============================================================
print_str:
    push rax
    push rcx
    push rdx
    push rdi

    mov  rdx, 0
    mov  rcx, rsi
.len_loop:
    cmp  byte [rcx], 0
    je   .len_done
    inc  rcx
    inc  rdx
    jmp  .len_loop
.len_done:

    mov  rax, 1
    mov  rdi, 1
    syscall

    pop  rdi
    pop  rdx
    pop  rcx
    pop  rax
    ret