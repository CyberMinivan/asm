;----------------------------;
;-- OpenSec Server Example --;
;----------------------------;

%define FILE_SIZE 1024  ; Max Response Size

global _start

; Socket Structure
struc sockaddr_in
  .sin_family resw 1
  .sin_port resw 1
  .sin_addr resd 1
  .sin_zero resb 8
endstruc

;-- BSS Section --;
section .bss
  sock resw 2   ; File Descriptor Variables
  client resw 2 ; FD Client

;-- Data Section --;
section .data
  ; File Variables
  filebuffer times FILE_SIZE db 0
  fd dw 0

  ; Messages
  intro db "[+] OpenSec Test Server", 0xA, 0          ; Intro Message

  argfail db "[-] Invalid Arguments Passed", 0xA      ; Invalid Arguments message
          db 0x9,"Usage: ./server <filename> <port>", 0xA

  notfound db "[-] File Not Found", 0xA,0
  opensocket db "[+] Creating Socket", 0xA, 0
  bindsocket db "[+] Binding to Port", 0xA, 0
  listensocket db "[+] Listening...", 0xA, 0
  accepted db "[*] Accepted Connection [*]", 0xA, 0

  pop_sa istruc sockaddr_in             ; Local Side Socket Address Structure
    at sockaddr_in.sin_family, dw 2
    at sockaddr_in.sin_port, dw 0x5c11
    at sockaddr_in.sin_addr, dd 0 
    at sockaddr_in.sin_zero, dd 0, 0
  iend
  sockaddr_in_len equ $ - pop_sa

;-- Code Section --;
section .text

;-- Convert 2nd Argument Into Hex --;
_convertport:
  ; Add String to Hex Code Here

  ret

;-- Print Function --;
_print:
  call _getlen
  mov rdx, rcx              ; Move Count to rdx
  mov rax, 1                ; SYS_WRITE
  mov rdi, 1                ; STDOUT FD
  syscall 
  ret

;-- Get Length Function --;
_getlen:
  xor rcx, rcx        ; Clear 
  xor rax, rax        ;    Registers
  .loop:
  inc rcx               ; Increment Length
  lea rax, [rsi + rcx]  ; Load Address of Next Char
  cmp byte [rax], 0     ; Compare byte to 0 (End of String)
  jne .loop             ; Jump back to loop if not 0
  ret  

;-- Start of Program --;
_start:
  mov r8, [rsp + 16]  ; Load First argument Address into r8
  mov r11, [rsp + 24] ; Second Argument
  mov rax, [rsp]      ; Obtain Argument Count
  push rax            ; Save Argument Count
  
  mov rsi, intro      ; Print Intro Message
  call _print

  pop rax             ; Pop Argument Count
  cmp rax, 3          ; Compare to 3 ("./server <filename> <port>")
  jne _invargs        ; If not Exit, Display & Exit

  call _convertport   ; Convert Port & Store
  call _readfile      ; Read File Into Response Buffer

  ; Begin Socket Programming
  mov word [sock], 0
  mov word [client], 0
  call _socket
  call _listen
  .mainloop:     ; Main Loop to Listen for Connections
    call _accept          ; Accept Connection
    mov rsi, accepted
    call _print
    call _response        ; Respond
    mov rdi, [client]     ; Move client FD to close
    call _close
    mov word [client], 0  ; Reset client FD
  jmp .mainloop

;-- Gracefully Exit --;
_exit:
  mov rax, 60         ; SYS_EXIT
  mov rdi, 0          ; Return Code
  syscall

;-- Invalid Arguments --;
_invargs:
  mov rsi, argfail
  call _print
  call _exit

;-- Read File Passed as Argument --;
_readfile:
  mov rax, 2  ; SYS_OPEN
  mov rsi, 0  ; Flags
  mov rdi, r8
  syscall

  test rax, rax
  js _filenotfound
  mov [fd], rax

  mov rax, 0    ; SYS_READ
  mov rdi, [fd]
  mov rsi, filebuffer
  mov rdx, FILE_SIZE
  syscall

  mov rdi, [fd]     ; Close FD
  call _close       ; SYS_CLOSE
  ret

;-- Create Socket --;
_socket:
  mov rsi, opensocket
  call _print

  mov rax, 41   ; SYS_SOCKET
  mov rdi, 2    ; Socket Family 
  mov rsi, 1    ; Type
  mov rdx, 0    ; Protocol
  syscall

  mov [sock], rax ; Move result into sock variable
  ret

;-- Bind & Listen --;
_listen:
  mov rsi, bindsocket
  call _print

  mov rax, 49       ; SYS_BIND
  mov rdi, [sock]   
  mov rsi, pop_sa
  mov rdx, sockaddr_in_len
  syscall
  push rdi
  push rdx

  mov rsi, listensocket
  call _print

  pop rdx
  pop rdi
  mov rax, 50       ; SYS_LISTEN
  mov rsi, 1
  syscall
  ret

;-- Accept Connection --;  
_accept:
  mov rax, 43       ; SYS_ACCEPT
  mov rdi, [sock]
  mov rsi, 0
  mov rdx, 0
  syscall
  
  mov [client], rax
  ret

;-- Close Socket --;
_close:
  mov rax, 3        ; SYS_CLOSE
  syscall
  ret

;-- Respond to Connection --;
_response:
  mov rax, 1
  mov rdi, [client]
  mov rsi, filebuffer 
  mov rdx, FILE_SIZE
  syscall
  ret

;-- File Not Found --;
_filenotfound:
  mov rsi, notfound
  call _print
  call _exit
