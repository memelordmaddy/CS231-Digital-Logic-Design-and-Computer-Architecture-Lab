.data
    .align 2
    com: .space 32

.text
main:

    addi $s0, $0, 0
    addi $t0, $0, 0
    sw $s0, com($t0)
    addi $s0, $0, 0
    addi $t0, $t0, 4
    sw $s0, com($t0)

    addi $s0, $0, -1
    addi $t0, $t0, 4
    sw $s0, com($t0)
    addi $s0, $0, 2
    addi $t0, $t0, 4
    sw $s0, com($t0)

    addi $s0, $0, 0
    addi $t0, $t0, 4
    sw $s0, com($t0)
    lw $s1, com($t0)
    addi $s0, $0, 2
    addi $t0, $t0, 4
    sw $s0, com($t0)
    lw $t1, com($t0)
    add $s1, $s1, $t1

    addi $s0, $0, -1
    addi $t0, $t0, 4
    sw $s0, com($t0)
    addi $s0, $0, -1
    addi $t0, $t0, 4
    sw $s0, com($t0)

    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 10
    syscall

    
    