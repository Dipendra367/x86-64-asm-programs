; ============================================================
;  Caesar Cipher (Interactive) - x86-64 NASM (Linux)
;  User types a message + shift, program encrypts & decrypts
;
;  Assemble & link:
;    nasm -f elf64 caesar_cipher.asm -o caesar_cipher.o
;    ld caesar_cipher.o -o caesar_cipher
;
;  Usage:
;    ./caesar_cipher
; ============================================================

section .data
    banner      db  "================================", 10
                db  "   Caesar Cipher - x86-64 ASM  ", 10
                db  "================================", 10, 0

    prompt_msg  db  10, "Enter message : ", 0
    prompt_shft db  "Enter shift (1-25): ", 0
    lbl_enc     db  10, "Encrypted : ", 0
    lbl_dec     db  "Decrypted : ", 0
    lbl_done    db  10, "Done!", 10, 0
    newline     db  10

section .bss
    input_buf   resb 256
    shift_buf   resb 8
    encrypted   resb 256
    decrypted   resb 256
    input_len   resq 1
    shift_len   resq 1

section .text
    global _start

_start:
    mov  rdi, banner
    call print_str

    ; ── Read message ─────────────────────────────────────────
    mov  rdi, prompt_msg
    call print_str

    mov  rax, 0
    mov  rdi, 0
    mov  rsi, input_buf
    mov  rdx, 255
    syscall
    mov  [input_len], rax

    ; Strip trailing newline
    mov  rcx, [input_len]
    test rcx, rcx
    jz   .no_strip
    dec  rcx
    cmp  byte [input_buf + rcx], 10
    jne  .no_strip
    mov  byte [input_buf + rcx], 0
    mov  [input_len], rcx
.no_strip:

    ; ── Read shift ───────────────────────────────────────────
    mov  rdi, prompt_shft
    call print_str

    mov  rax, 0
    mov  rdi, 0
    mov  rsi, shift_buf
    mov  rdx, 7
    syscall
    mov  [shift_len], rax

    call atoi               ; result in eax

    ; Clamp to 1–25
    cmp  eax, 1
    jge  .min_ok
    mov  eax, 1
.min_ok:
    cmp  eax, 25
    jle  .max_ok
    mov  eax, 25
.max_ok:
    mov  r15d, eax

    ; ── Encrypt ──────────────────────────────────────────────
    mov  rsi, input_buf
    mov  rdi, encrypted
    mov  ecx, r15d
    call caesar_encrypt

    mov  rdi, lbl_enc
    call print_str
    mov  rdi, encrypted
    call print_str
    call print_newline

    ; ── Decrypt ──────────────────────────────────────────────
    mov  rsi, encrypted
    mov  rdi, decrypted
    mov  ecx, r15d
    call caesar_decrypt

    mov  rdi, lbl_dec
    call print_str
    mov  rdi, decrypted
    call print_str
    call print_newline

    mov  rdi, lbl_done
    call print_str

    mov  rax, 60
    xor  rdi, rdi
    syscall


; ============================================================
;  atoi — convert shift_buf digits → eax
; ============================================================
atoi:
    xor  eax, eax
    mov  rsi, shift_buf
.loop:
    movzx ecx, byte [rsi]
    cmp  cl, 10
    je   .done
    cmp  cl, 0
    je   .done
    cmp  cl, '0'
    jl   .done
    cmp  cl, '9'
    jg   .done
    imul eax, eax, 10
    sub  cl, '0'
    add  eax, ecx
    inc  rsi
    jmp  .loop
.done:
    ret


; ============================================================
;  caesar_encrypt — rsi=src, rdi=dst, ecx=shift
; ============================================================
caesar_encrypt:
    push rbx
    push r12
    push r13

    mov  rbx, rsi
    mov  r12, rdi
    mov  r13d, ecx

.loop:
    movzx eax, byte [rbx]
    test al, al
    jz   .done

    cmp  al, 'A'
    jl   .not_upper
    cmp  al, 'Z'
    jg   .not_upper
    sub  al, 'A'
    add  eax, r13d
    xor  edx, edx
    mov  ecx, 26
    div  ecx
    add  dl, 'A'
    mov  byte [r12], dl
    jmp  .next

.not_upper:
    cmp  al, 'a'
    jl   .passthrough
    cmp  al, 'z'
    jg   .passthrough
    sub  al, 'a'
    add  eax, r13d
    xor  edx, edx
    mov  ecx, 26
    div  ecx
    add  dl, 'a'
    mov  byte [r12], dl
    jmp  .next

.passthrough:
    mov  byte [r12], al

.next:
    inc  rbx
    inc  r12
    mov  ecx, r13d
    jmp  .loop

.done:
    mov  byte [r12], 0
    pop  r13
    pop  r12
    pop  rbx
    ret


; ============================================================
;  caesar_decrypt — reverse shift then reuse encrypt
; ============================================================
caesar_decrypt:
    push rbx
    mov  ebx, 26
    sub  ebx, ecx
    mov  ecx, ebx
    pop  rbx
    jmp  caesar_encrypt


; ============================================================
;  print_str — rdi = null-terminated string
; ============================================================
print_str:
    push rbx
    mov  rbx, rdi
    xor  rcx, rcx
.len:
    cmp  byte [rbx + rcx], 0
    je   .write
    inc  rcx
    jmp  .len
.write:
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, rbx
    mov  rdx, rcx
    syscall
    pop  rbx
    ret


; ============================================================
;  print_newline
; ============================================================
print_newline:
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, newline
    mov  rdx, 1
    syscall
    ret