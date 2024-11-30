.data 

.text
.globl main
main:
    addi $s0, $zero, 30
    addi $s1, $zero, 5
    div $s2, $s0, $s1  #can do div with two arguments so that quotient goes to lo and reminder goes to high

    li $v0, 1
    move $a0, $s2
    syscall

    li $v0, 10
    syscall