.text
#.globl main
main:
    #addi $t0, $zero, 1
    #addi $t1, $zero, 2
    lui $t0, 0x2000
    ori $t0, $t0, 0x0001

    lui $t1, 0x1000
    ori $t1, $t1, 0x0002

    add $s0, $t0, $t1
    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 10
    #move $a0, $s0
    syscall

