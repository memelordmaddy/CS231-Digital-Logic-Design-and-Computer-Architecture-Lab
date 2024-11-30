.data

.text
.globl main
main:
    #sll multiplies a numbe rby  2^i
    addi $s0, $zero, 6
    sll $s0, $s0, 2 # 6 * 2^2

    li $v0,1
    move $a0, $s0
    syscall

    li $v0, 10
    syscall 