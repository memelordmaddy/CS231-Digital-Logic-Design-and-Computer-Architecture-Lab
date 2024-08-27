.data 
    number1: .word 70
    number2: .word 71
.text
.globl main
main:
    lw $s0, number1
    lw $s1, number2
    sub $t2, $s0, $s1
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 10
    syscall
