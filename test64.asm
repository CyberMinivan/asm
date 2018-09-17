
section .data
  msg db "Hello World", 0xA, 0

section .text
global _start

_start:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, 0xC
  syscall

  mov rax, 60
  mov rdi, 0
  syscall



