%include "asm_io.inc"
global asm_main

section .data
  peg_array: resb 9

section .bss

section .text

asm_main:
  enter 0, 0

  mov eax, dword [ebp+8]   ; argc
  cmp eax, 2               ; the correct number of args is 1
  jne WRONG_ARGC
  call print_int           ; display argc
  call print_nl

  mov ebx, dword [ebp+12]  ; address of argv[]
  mov eax, dword [ebx+4]   ; get argv[0] argument -- ptr to string
  call print_string        ; display argv[0] arg
  call print_nl

  WRONG_ARGC:

  leave
  ret

