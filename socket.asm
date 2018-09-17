; Minivan Socket Server
global _start

struc sockaddr_in
  .sin_family resw 1
  .sin_port resw 1
  .sin_addr resd 1
  .sin_zero resb 8
endstruc

section .bss
  sock resw 2
  client resw 2

section .data
  msg db "[+] Minivan Server", 0xA, 0
  len_msg equ $ - msg

  resp db "[-] Server Response", 0xA, 0
  len_resp equ $ - resp

  ; sockaddr_in structure for the address the listening socket binds to
  pop_sa istruc sockaddr_in
    at sockaddr_in.sin_family, dw 2            ; AF_INET
    at sockaddr_in.sin_port, dw 0xa1ed        ; port 60833
    at sockaddr_in.sin_addr, dd 0             ; localhost
    at sockaddr_in.sin_zero, dd 0, 0
  iend
  sockaddr_in_len     equ $ - pop_sa

section .text

_start:
  ; Show Message
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, len_msg
  syscall

  ; Create & Handle Socket
  mov word [sock], 0
  mov word [client], 0
  call _socket
  call _listen
  .loop:
    call _accept
    call _response
    mov rdi, [client]
    call _close
    mov word [client], 0
  jmp .loop

  call _exit

_socket:
  ; Create Socket
  mov rax, 41
  mov rdi, 2
  mov rsi, 1
  mov rdx, 0
  syscall
  mov [sock], rax
  ret

_listen:
  ; SYS_BIND
  mov rax, 49
  mov rdi, [sock]
  mov rsi, pop_sa
  mov rdx, sockaddr_in_len
  syscall

  ; SYS_LISTEN
  mov rax, 50
  mov rsi, 1
  syscall
  ret

_accept:
  ; SYS_ACCEPT
  mov rax, 43
  mov rdi, [sock]
  mov rsi, 0
  mov rdx, 0
  syscall
  mov [client], rax
  ret

_response:
  ; Send Response
  mov rax, 1
  mov rdi, [client]
  mov rsi, resp
  mov rdx, len_resp
  syscall
  ret

_close:
  ; Close Socket
  mov rax, 3
  syscall
  ret 

_exit:
  mov rax, 60
  mov rdi, 0
  syscall

