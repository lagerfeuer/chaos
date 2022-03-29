    bits 16                         ; tell NASM this is 16 bit code
    org 0x7c00                      ; tell NASM to start outputting stuff at offset 0x7c00

    mov ax, 0                   ; load 0 into ax
    mov ds, ax                  ; segment pointer
    mov es, ax                  ; segment pointer
    mov ss, ax                  ; segment pointer
    mov sp, 0x7c00              ; stack pointer

    mov si, welcome_msg
    call print

    ;; main
main:
    mov si, prompt
    call print

    mov di, buffer
    call get_str

    mov si, buffer
    cmp byte [si], 0            ; blank line?
    je main

    mov si, buffer
    mov di, cmd_info
    call strcmp
    jc .info

    mov si, buffer
    mov di, cmd_ping
    call strcmp
    jc .ping

    mov si, buffer
    mov di, cmd_exit
    call strcmp
    jc .exit

    jmp main

.info:
    mov si, info
    call print
    jmp main

.ping:
    mov si, pong
    call print
    jmp main

.exit:
    cli
    hlt

    ;; data
welcome_msg db 'Welcome to ChaOS!', 0x0d, 0x0a, 0 ; 0x0d,0x0a are \r\n
prompt db '> ', 0
cmd_info db 'info', 0
cmd_ping db 'ping', 0
cmd_exit db 'exit', 0
pong db 'pong', 0x0d, 0x0a, 0
info db 'ChaOS v0.0.2', 0x0d, 0x0a, 0
buffer times 64 db 0

    ;; print
print:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0e
    int 0x10

    jmp print

.done:
    ret

    ;; get_str
get_str:
    xor cl, cl
.loop:
    mov ah, 0
    int 0x16

    cmp al, 0x08                ; backspace?
    je .backspace

    cmp al, 0x0d                ; enter?
    je .done

    cmp cl, 0x3f                ; 63 chars in buffer?
    je .loop

    mov ah, 0x0e
    int 0x10                    ; print char

    stosb                       ; save char in buffer
    inc cl
    jmp .loop

.backspace:
    cmp cl, 0                   ; start of input?
    je .loop                    ; ignore

    dec di                      ; delete last char
    mov byte [di], 0
    dec cl                      ; decrement counter too

    mov ah, 0x0e
    mov al, 0x08
    int 0x10                    ; backspace
    mov al, ' '
    int 0x10                    ; blank char
    mov al, 0x08
    int 0x10                    ; backspace

    jmp .loop

.done:
    mov al, 0                   ; null terminator
    stosb

    mov ah, 0x0e
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10                    ; newline

    ret

    ;; strcmp
strcmp:
.loop:
   mov al, [si]
   mov bl, [di]
   cmp al, bl
   jne .notequal

   cmp al, 0
   je .done

   inc di
   inc si
   jmp .loop

.notequal:
   clc
   ret

.done:
   stc
   ret

    ;; END
    times 510 - ($-$$) db 0         ; pad remaining 510 bytes with zeroes
    dw 0xaa55                       ; magic bootloader magic - marks this 512 byte sector bootable!
