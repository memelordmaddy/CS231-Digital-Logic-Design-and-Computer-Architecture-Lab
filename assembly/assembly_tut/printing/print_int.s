.data 
    num: .word  69
.text
.globl main
main:
    li $v0, 1
    lw $a0, num
    syscall
    li $v0, 10
    syscall

