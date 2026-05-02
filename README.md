# x86-64 Assembly Programs

A collection of four classic programs written in x86-64 NASM assembly language for Linux. Each program runs entirely without a C runtime — only raw Linux syscalls.

---

## Requirements

- [NASM](https://nasm.us/) assembler
- GNU `ld` linker
- Linux x86-64 (or WSL on Windows)

Install on Ubuntu/Debian:

```bash
sudo apt install nasm binutils
```

---

## Repository Structure

```
x86-64-asm-programs/
├── README.md
├── screenshots/
│   ├── caesar_cipher_output.png
│   ├── bubble_sort_output.png
│   ├── linear_search_output.png
│   └── fibonacci_output.png
├── 01_caesar_cipher/
│   └── caesar_cipher.asm
├── 02_bubble_sort/
│   └── bubble_sort.asm
├── 03_linear_search/
│   └── linear_search.asm
└── 04_fibonacci/
    └── fibonacci.asm
```

---

## Programs

### 1. Caesar Cipher

Encrypts and decrypts a user-supplied message using a shift value between 1 and 25. Handles wrap-around for both uppercase and lowercase letters and preserves non-alphabetic characters.

**Build & Run:**

```bash
cd 01_caesar_cipher
nasm -f elf64 caesar_cipher.asm -o caesar_cipher.o
ld caesar_cipher.o -o caesar_cipher
./caesar_cipher
```



---

### 2. Bubble Sort

Sorts a hardcoded array of 64-bit integers in ascending order using the bubble sort algorithm. Prints the array before and after sorting.

**Build & Run:**

```bash
cd 02_bubble_sort
nasm -f elf64 bubble_sort.asm -o bubble_sort.o
ld bubble_sort.o -o bubble_sort
./bubble_sort
```



---

### 3. Linear Search

Takes a number typed by the user and searches for it in a predefined array. Reports the index if found, or a not-found message if absent.

**Build & Run:**

```bash
cd 03_linear_search
nasm -f elf64 linear_search.asm -o linear_search.o
ld linear_search.o -o linear_search
./linear_search
```



### 4. Fibonacci

Takes a number N from the user and prints the first N terms of the Fibonacci sequence, displaying each index alongside its value.

**Build & Run:**

```bash
cd 04_fibonacci
nasm -f elf64 fibonacci.asm -o fibonacci.o
ld fibonacci.o -o fibonacci
./fibonacci
```


---

## Concepts Covered

| Program        | Key Concepts                                              |
|----------------|-----------------------------------------------------------|
| Caesar Cipher  | String iteration, modular arithmetic, syscalls            |
| Bubble Sort    | Arrays, nested loops, indexed addressing, in-place swap   |
| Linear Search  | Array traversal, comparison, user input, early exit       |
| Fibonacci      | Iterative computation, register management, user input    |

---

## Notes

- All programs use Linux syscalls directly (`sys_read`, `sys_write`, `sys_exit`) with no external libraries.
- Registers follow the System V AMD64 ABI calling convention.
- Assembled and tested on Ubuntu 24.04 with NASM 2.16.

---

## Author

**Dipendra**  
Learning low-level programming through x86-64 assembly on Linux.
