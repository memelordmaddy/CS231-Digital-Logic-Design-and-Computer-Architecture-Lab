.data 
   prompt: .asciiz "input an integer\n"
   prompt1: .asciiz "input another integer\n"
   op: .asciiz "sum of the given integers: "

.text
main:

    li $v0, 4
    la $a0, prompt
    syscall


    li $v0, 5
    syscall
    move $s0, $v0

    li $v0, 4
    la $a0, prompt1
    syscall

    li $v0, 5
    syscall

    add $s0, $v0, $s0

    li $v0, 4
    la $a0, op
    syscall

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 10
    syscall

