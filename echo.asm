global _start
section .text

_start:
    pop	esi	        ; Get the number of arguments
    pop	ebx	        ; Pop the program name, we don't need this so we'll just overwrite it

    mov dx,0xA     ;The newline character
    dec esi      ; If there are no arguments just exit
    jz _exit

    pop	ebx		      ; Get argument
    ;compare ebx with '-n' to see if they're the same
    mov edi, [ebx]
    and edi, 0xFFFFFF ; Mask the bits we don't need
    cmp edi,0x6e2d ;Check for '-n'
    jne _main
_removenl:
    xor dx,dx ;Removes the newline character from memory
    dec esi
    jz _exit
    pop ebx
_main:
    ;strlen(edi)
    ;Here we have an assembly implementation of glibc's strlen.c
    ;Yes, that's right, I'm using *that* method because it's REALLY fast
    mov edi, ebx
    ;Get the string length for string edi and put it in eax
_s:
    mov ecx,[edi]
    add edi,4     ;Move to the next 'double word' (because we'll be decreasing from it)
    ; Wooo magical numbers!
    and ecx, 0x7F7F7F7F
    sub ecx, 0x01010101
    and ecx, 0x80808080
    xor ecx, 0  ;compare ecx with 0
    jz _s ;If none of them were zeros loops back to s
    ;otherwise let's track down the one that was zero which will be represented a 0x80
    sub edi, 4      ;Remove the 'add edi, 2' that we did before
    test ecx, 0x80
    jnz _cont


    inc edi
    test ecx, 0x8000
    jnz _cont


    inc edi
    test ecx, 0x800000
    jnz _cont

    inc edi

_cont:
    mov ecx,ebx ;Save the original starting point in ecx, we don't want to modify ebx
    sub ecx, edi  ;Get the difference
    neg ecx ;It's going to be negative so make it positive
    mov byte [ebx+ecx],32 ; Put a space in between each argument to replace the string terminator
    dec esi          ; Decrease arg count
    jnz _main        ; If this is the last argument exit


_exit:
    ;Append a newline to the end if we have a newline
    mov [ebx+ecx],dx
    inc ecx ;Increase the length by one
    ; Print the string
    mov edx,ecx     ; String length
    mov ecx,ebx     ; String
    mov ebx,1       ; stdout
    mov eax,4       ; sys_write
    int 0x80        ; Kernel interrupt

    ;Exit with code 0
    mov eax, 1
    xor ebx, ebx
    int 0x80
