bits 32
global main

section .data
  msg db "Hello World", 0xA, 0

section .text

main:
  mov edx, 0xC
  mov ecx, msg
  mov ebx, 1
  mov eax, 4
  int 0x80

  mov ebx, 0
  mov eax, 1
  int 0x80