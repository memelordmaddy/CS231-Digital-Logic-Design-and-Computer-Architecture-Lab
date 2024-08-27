.data 
    number1: .word 60
    number2: .word 9
.text
.globl main
main:
    lw $s0, number1
    lw $s1, number2
    add $t2, $s1, $s0
    li $v0, 1
    add $a0, $zero, $t2
    syscall
    li $v0, 10
    syscall
