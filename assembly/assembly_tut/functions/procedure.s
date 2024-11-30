.data 
    text: .asciiz "Hello World"

.text 
.globl main
main:
    jal print_hello_world #function call

    li $v0, 10
    syscall

    print_hello_world:
        li $v0, 4
        la $a0, text
        syscall

        jr $ra # give controll back to where the function was called from
