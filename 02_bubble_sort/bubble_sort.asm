; ============================================================
; bubble_sort.asm — x86-64 NASM
; Bubble Sort on an integer array (ascending order)
;
; Build & Run:
;   nasm -f elf64 bubble_sort.asm -o bubble_sort.o
;   ld bubble_sort.o -o bubble_sort
;   ./bubble_sort
; ============================================================

section .data
    array       dq  64, 25, 12, 22, 11    ; 64-bit integers to sort
    array_len   equ 5                      ; number of elements

    msg_before  db  "Before: ", 0
    msg_after   db  "After:  ", 0
    msg_done    db  10, "Done!", 10, 0
    space       db  " ", 0
    newline     db  10, 0

section .bss
    num_buf     resb 20                    ; buffer for int->string conversion

section .text
    global _start

; ============================================================
; _start
; ============================================================
_start:
    ; --- print "Before: " and the unsorted array ---
    mov  rsi, msg_before
    call print_str

    mov  rcx, array_len
    mov  rbx, 0                     ; index
.print_before:
    push rcx
    push rbx
    mov  rax, [array + rbx*8]
    call print_int
    mov  rsi, space
    call print_str
    pop  rbx
    pop  rcx
    inc  rbx
    loop .print_before

    mov  rsi, newline
    call print_str

    ; --- bubble sort ---
    mov  r8, array_len              ; r8 = n (outer loop counter)

.outer_loop:
    dec  r8
    jz   .sort_done                 ; if r8 == 0, sorted
    mov  r9, 0                      ; r9 = inner index i

.inner_loop:
    cmp  r9, r8
    jge  .outer_loop                ; if i >= n-pass, next pass

    mov  rax, [array + r9*8]        ; rax = array[i]
    mov  rdx, [array + r9*8 + 8]    ; rdx = array[i+1]
    cmp  rax, rdx
    jle  .no_swap                   ; if array[i] <= array[i+1], skip

    ; swap
    mov  [array + r9*8],     rdx
    mov  [array + r9*8 + 8], rax

.no_swap:
    inc  r9
    jmp  .inner_loop

.sort_done:

    ; --- print "After: " and sorted array ---
    mov  rsi, msg_after
    call print_str

    mov  rcx, array_len
    mov  rbx, 0
.print_after:
    push rcx
    push rbx
    mov  rax, [array + rbx*8]
    call print_int
    mov  rsi, space
    call print_str
    pop  rbx
    pop  rcx
    inc  rbx
    loop .print_after

    mov  rsi, newline
    call print_str

    ; --- print "Done!" and exit ---
    mov  rsi, msg_done
    call print_str

    mov  rax, 60                    ; sys_exit
    xor  rdi, rdi
    syscall

; ============================================================
; print_int  —  print signed 64-bit integer in rax
; ============================================================
print_int:
    push rbp
    mov  rbp, rsp

    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    lea  rdi, [num_buf + 19]        ; point to end of buffer
    mov  byte [rdi], 0
    mov  rbx, 10
    mov  rcx, 0                     ; digit count

    ; handle zero
    test rax, rax
    jnz  .convert
    dec  rdi
    mov  byte [rdi], '0'
    inc  rcx
    jmp  .print_num

.convert:
    ; handle negative
    push rax
    sar  rax, 63
    and  rax, rax
    pop  rax
    jns  .pos_num

    push rax
    neg  rax
    push rax
    dec  rdi
    mov  byte [rdi], '-'
    inc  rcx
    pop  rax
    push rax
    jmp  .digit_loop

.pos_num:
    push rax

.digit_loop:
    pop  rax
    test rax, rax
    jz   .print_num
    xor  rdx, rdx
    div  rbx                        ; rax = quotient, rdx = remainder
    push rax
    add  dl, '0'
    dec  rdi
    mov  [rdi], dl
    inc  rcx
    jmp  .digit_loop

.print_num:
    ; sys_write(1, rdi, rcx)
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
; print_str  —  print null-terminated string at rsi
; ============================================================
print_str:
    push rax
    push rcx
    push rdx
    push rdi

    ; find length
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