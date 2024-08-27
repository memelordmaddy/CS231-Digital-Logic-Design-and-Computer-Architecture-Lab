.data 
    
.text
.globl main
main:
    addi $s0, $zero, 3
    addi $s1, $zero, 23
    mul $t0, $s0, $s1 # max 16 bit * 16 bit mult allows bigger

    li $v0, 1
    add $a0, $t0, $zero
    syscall
    li $v0, 10
    syscall
