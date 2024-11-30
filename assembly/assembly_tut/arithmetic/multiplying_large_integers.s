.data 
.text
.globl main
main:
    addi $s0, $zero, 32767
    addi $s0, $s0, 32767
    addi $s0, $s0, 2
    addi $s1, $zero, 32767
    addi $s1, $s1, 32767
    addi $s1, $s1, 2

    mult $s0, $s1 
    mflo $s2
    mfhi $s3

    li $v0, 1
    move $a0, $s3 #op is hexadecimal
    syscall

    li $v0, 1
    move $a0, $s2
    syscall

    li $v0, 10
    syscall
