org 0x0

_start:
    jmp main_entry_point

ola_msg: db "Ola, ", 0
user_name_buffer: times 31 db 0
prompt_msg: db "Digite seu nome (max 30 chars): ", 0

print_string:
    lodsb            
    cmp al, 0
    jz .end_print
    mov ah, 0x0e
    int 0x10   
    jmp print_string
.end_print:
    ret

read_input:
    xor di, di         

    ; Limpa o buffer do teclado da BIOS antes de iniciar a leitura
.clear_buffer:
    mov ah, 0x01
    int 0x16
    jz .start_read_loop
    mov ah, 0x00
    int 0x16             
    jmp .clear_buffer

.start_read_loop:
    mov ah, 0x00
    int 0x16            

    cmp al, 0x08    
    je .handle_backspace

    cmp al, 0x0D         
    je .end_read_input

    cmp al, 0x20         
    jb .start_read_loop
    cmp al, 0x7E
    ja .start_read_loop

    cmp di, 30
    jge .start_read_loop

    mov ah, 0x0e
    int 0x10

    mov [user_name_buffer + di], al
    inc di

    jmp .start_read_loop

.handle_backspace:
    cmp di, 0
    je .start_read_loop

    dec di

    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10

    jmp .start_read_loop

.end_read_input:
    mov ah, 0x0e
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10

    mov byte [user_name_buffer + di], 0 
    ret

main_entry_point:
    cli
    mov ax, 0x7c0         
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov si, prompt_msg
    call print_string

    call read_input

    mov si, ola_msg
    call print_string

    mov si, user_name_buffer
    call print_string

    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55