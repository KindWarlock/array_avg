%macro pushd 0
    push eax
    push ebx
    push ecx
    push edx
%endmacro
 
%macro popd 0
    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro
 
%macro print 2
    pushd
    mov edx, %1 
    mov ecx, %2 
    mov ebx, 1
    mov eax, 4
    int 0x80
    popd
%endmacro
 
%macro dprint 0
    push edx
    mov bx, 0 
    mov ecx, 10
%%_divide: 
    mov edx, 0
    div ecx 
    push dx 
    inc bx  
    test eax, eax
    jnz %%_divide
 
%%_digit:
    pop ax
    add ax, '0' 
    mov [result], ax
    print 1, result
    dec bx
    cmp bx, 0
    jg %%_digit
    pop edx
%endmacro

%macro divide 2 ; //-like division
    push eax
    push edx
    
    mov edx, 0 
    mov eax, %1
    mov ecx, %2
    div ecx
    
    mov ecx, eax ; result to ecx
    
    pop edx
    pop eax
%endmacro

%macro avg 2 
    mov ecx, 0
    mov eax, 0
    mov edx, 0
%%_sum:
    add eax, %1[ecx]
    add ecx, 4
    cmp ecx, %2
    jl %%_sum
    
    divide xlen, 4
    
    div ecx
%endmacro

%macro print_dec 0 ; from eax and edx
    dprint
    print 1, point 
    mov eax, edx
    dprint
    print nlen, newline
%endmacro

%macro find_dec 2 ; точность до 3 знаков
    pushd
    mov eax, %1
    mov ebx, 100 ; counter
    mov [temp], dword 0
    
%%_remainder:
    mov ecx, 10
    mul ecx
    mov ecx, %2
    divide ecx, 4
    
    div ecx
    
    push edx
    mul ebx
    pop edx
    add [temp], eax
    mov eax, edx
    
    divide ebx, 10
    mov ebx, ecx 
    
    test ebx, ebx
    
    jnz %%_remainder
    popd
%endmacro

section .text
 
global _start
 
_start:
    avg x, xlen
    mov [avg_one], eax
    mov [avg_one_dec], edx

    
    avg y, ylen
    mov [avg_two], eax
    mov [avg_two_dec], edx
    
    
    mov edx, [avg_two_dec]
    sub edx, [avg_one_dec]
    mov eax, edx
    
    cmp edx, dword 0
    jge _sub
    mov eax, edx
    mov ecx, dword -1
    mul ecx
    mov edx, eax
    sub [avg_two], dword 1
_sub:
    mov eax, [avg_two]
    sub eax, [avg_one]
    cmp eax, dword 0
    
    jge _print
    
    push edx
    mov ecx, dword -1
    mul ecx
    pop edx
_print:
    find_dec edx, xlen
    mov edx, [temp]
    print_dec
    
    print nlen, newline
    print len, message
    print nlen, newline
 
    mov eax, 1
    int 0x80
 
section .data
    message db "Done"
    len equ $ - message 
    newline db 0xA, 0XD
    nlen equ $ - newline
    point db ','
    
    x dd 5, 3, 3
    xlen equ $ - x
    y dd 5, 3, 2
    ylen equ $ - y
    
section .bss
    avg_one resd 1
    avg_one_dec resd 1
    avg_two resd 1
    avg_two_dec resd 1
    
    result resb 1
    
    temp resd 1
 
