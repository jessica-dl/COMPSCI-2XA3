%include "asm_io.inc"
global asm_main

section .data ; declaration of messages to be shown to the user
    too_long:     db "Error: input should be one character", 0
    not_between:  db "Error: input should be between 2 and 9", 0
    end_showp:    db "XXXXXXXXXXXXXXXXXXXXXXX", 10, 0
    init_config:  db "intial configuration", 10, 10, 0
    final_config: db "final configuration", 10, 10, 0
    
section .bss ; declaration of variables holding the array and the number of pegs it has
    PEG_ARRAY: resd 9
    NUM_PEGS:  resd 1

section .text

sorthem:
enter 0, 0

    pusha
    
    mov ebx, dword [ebp + 8]    ; holds the address of the array
    mov ecx, dword [ebp + 12]   ; holds the number of pegs in the array 

    cmp ecx, dword 1            ; if the number of pegs is 1, return
    je BASE_CASE
    jmp REC_CALL    

    BASE_CASE:
        jmp EXIT_SORTHEM        ; returns

    REC_CALL:
        add ebx, dword 4        ; looks at next element in the array
        sub ecx, dword 1        ; subtracts one from the pegs number
        push ecx
        push ebx        
        call sorthem            ; calls sorthem on the new values
        add esp, dword 8        ; restores the stack
        sub ebx, dword 4        ; restores the original values
        add ecx, dword 1        
         
    mov edx, dword 1            ; this is the loop counter
    SWAP:
        cmp edx, ecx            ; swaps until it runs out of pegs
        je END_SWAP
        
        push ecx                ; pushes to save value of ecx
        add ebx, dword 4        ; moves to next element in array (arr[i])

        mov ecx, [ebx]
        cmp [ebx - 4], ecx      ; if arr[i - 1] < arr [i], swap them
        jl SWAP_VALS            ; sorts in descending order, so arr[i - 1] should be < arr[i]
        jmp CONT
    
        SWAP_VALS:
            mov eax, [ebx - 4]  ; mov val at arr[i - 1] to tmp (eax)
            mov [ebx - 4], ecx  ; mov arr[i] to arr[i - 1]
            mov [ebx], eax      ; mov arr[i - 1] to arr[i]

        CONT:
            add edx, dword 1    ; increment for loop counter
            pop ecx             ; pop to restore the value of ecx
            jmp SWAP            ; jump to the top of the loop

    END_SWAP:
        push dword [NUM_PEGS]   ; calling showp requires the number of pegs in the array
        push PEG_ARRAY          ; it also requires the address of the array     
        call showp
        ;call read_char          ; this waits for user input before continuing to continuing to sort the array
        add esp, 8

    EXIT_SORTHEM:
        popa
        leave
        ret

print_o_line:
enter 0, 0
    pusha

    mov ebx, eax                ; takes in the size of elements
    mov ecx, ebx                ; this will be the number of 'o's to print

    mov edx, 11                 ; this is the number of spaces for formatting
    sub edx, ebx                ; subtracts based on the size of the element

    PRINT_SPACE:
    
        cmp edx, dword 0        
        je END_SPACE

        mov eax, ' '           
        call print_char         ; print the character ' '
        sub edx, 1
        jmp PRINT_SPACE

    END_SPACE:
    
    PRINT_O:
        
        cmp ebx, dword 0        ; prints as many 'o's as the size of the element
        je END_O
    
        mov eax, 'o'
        call print_char         ; prints the character 'o'

        sub ebx, 1
        jmp PRINT_O

    END_O:
    
    mov eax, '|'                ; prints '|' to separate each side of the pyramid
    call print_char

    PRINT_OS:

        cmp ecx, dword 0
        je END_OS

        mov eax, 'o'
        call print_char         ; prints the 'o's on the other side of the pyramid

        sub ecx, 1
        jmp PRINT_OS
 
    END_OS:
    
    popa
    leave
    ret

showp:
enter 0, 0
    
    pusha

    mov ebx, dword [ebp + 12]   ; takes in the address of the array
    shl ebx, 2                  ; 
    sub ebx, 4

    LOOP:
 
        cmp ebx, dword 0
        jl END_LOOP        

        push ebx                ; saves the values of ebx

        add ebx, [ebp + 8]    
        mov eax, dword [ebx]    ; uses eax to call print_o_line subroutine
        call print_o_line       ; prints the line of 'o's, including the separter char '|'
        call print_nl

        pop ebx                 ; restores the value of ebx

        sub ebx, dword 4
        jmp LOOP
 
    END_LOOP:
        mov eax, end_showp      ; prints a line of char 'X' 
        call print_string
        call print_nl

        call read_char          ; this waits for user input before continuing to continuing to sort the array

    jmp EXIT_SHOWP

    EXIT_SHOWP:
        leave
        ret


asm_main:
    enter 0, 0

    mov ecx, dword [ebp + 8]    ; argc
    cmp ecx, 2                  ; the correct number of args is 1, including the call makes it 2
    jne EXIT

    mov ebx, dword [ebp + 12]   ; address of argv[]
    mov ecx, dword [ebx + 4]    ; get argv[0] argument -- ptr to string
    mov al, [ecx]               ; moves it to a one byte register 

    sub al, byte '0'            ; turns it into a number from a char
    mov [NUM_PEGS], al          ; this is the number of pegs

    cmp byte [ecx + 1], byte 0  ; checks to see if the input string is the right length
    jne TOO_LONG
    
    cmp [NUM_PEGS], byte 2
    jl NOT_BETWEEN               ; if the input is less than 2, exit

    cmp [NUM_PEGS], byte 9
    jg NOT_BETWEEN               ; if the input is greater than 9, exit

    push dword [NUM_PEGS]
    push PEG_ARRAY
    call rconf                   ; calls rconf to generate array

    add esp, 8
 
    push dword [NUM_PEGS]        
    push PEG_ARRAY
    mov eax, init_config         ; prints string to show user the initial configuration 
    call print_string   
    call showp                   ; prints the initial configuration of the array
    call sorthem                 ; sorts the array
    mov eax, final_config        ; prints string to show user the final configuration   
    call print_string
    call showp                   ; prints the final configuration

    add esp, 8

    jmp EXIT

TOO_LONG:                        ; prints error message if the argument is not the right length
    mov eax, too_long
    call print_string
    call print_nl
    jmp EXIT

NOT_BETWEEN:                     ; prints error message if the argument isn't between 2 and 9
    mov eax, not_between
    call print_string
    call print_nl
    jmp EXIT

EXIT:                            ; exits the program
    leave
    ret

