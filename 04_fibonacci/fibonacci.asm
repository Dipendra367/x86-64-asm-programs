; ============================================================
; fibonacci.asm — x86-64 NASM
; Fibonacci: user types N, prints first N Fibonacci numbers
;
; Build & Run:
;   nasm -f elf64 fibonacci.asm -o fibonacci.o
;   ld fibonacci.o -o fibonacci
;   ./fibonacci
; ============================================================

section .data
    banner_top  db  "==============================", 10, 0
    banner_bot  db  "==============================", 10, 0
    title       db  "   Fibonacci — x86-64 ASM     ", 10, 0

    msg_prompt  db  "Enter N (how many terms): ", 0
    msg_seq     db  10, "Fibonacci Sequence:", 10, 0
    msg_done    db  10, "Done!", 10, 0

    arrow       db  " -> ", 0
    newline     db  10, 0

section .bss
    input_buf   resb 20
    num_buf     resb 25

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

    ; --- prompt ---
    mov  rsi, msg_prompt
    call print_str

    ; --- read N ---
    mov  rax, 0
    mov  rdi, 0
    mov  rsi, input_buf
    mov  rdx, 20
    syscall

    mov  rsi, input_buf
    call str_to_int
    mov  r12, rax               ; r12 = N

    ; --- print header ---
    mov  rsi, msg_seq
    call print_str

    ; --- edge case: N <= 0 ---
    cmp  r12, 0
    jle  .done

    ; --- init Fibonacci ---
    mov  r13, 0                 ; prev  (F0)
    mov  r14, 1                 ; curr  (F1)
    mov  r15, 0                 ; index counter

.fib_loop:
    cmp  r15, r12
    jge  .done

    ; print index
    mov  rax, r15
    call print_int
    mov  rsi, arrow
    call print_str

    ; print F(index)
    mov  rax, r13
    call print_int
    mov  rsi, newline
    call print_str

    ; next Fibonacci: next = prev + curr
    mov  rax, r13
    add  rax, r14
    mov  r13, r14               ; prev = curr
    mov  r14, rax               ; curr = next

    inc  r15
    jmp  .fib_loop

.done:
    mov  rsi, msg_done
    call print_str

    mov  rax, 60
    xor  rdi, rdi
    syscall

; ============================================================
; str_to_int — convert newline/null-terminated string at rsi
;              returns integer in rax
; ============================================================
str_to_int:
    xor  rax, rax
    xor  rcx, rcx
.next_char:
    movzx rcx, byte [rsi]
    cmp  cl, 10
    je   .conv_done
    cmp  cl, 0
    je   .conv_done
    cmp  cl, '0'
    jl   .conv_done
    cmp  cl, '9'
    jg   .conv_done
    sub  cl, '0'
    imul rax, rax, 10
    add  rax, rcx
    inc  rsi
    jmp  .next_char
.conv_done:
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

    lea  rdi, [num_buf + 24]
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
    jmp  .digit_loop

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