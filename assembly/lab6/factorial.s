.text
main:
    li $a0, 7
    jal factorial

    li $v0, 1
    move $a0, $v1
    syscall

    li $v0, 10
    syscall


factorial:
    addi $t0, $zero, 1
    beq $a0, $t0, base_case
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    addi $a0, $a0, -1
    jal factorial
    lw $a0, 4($sp)
    mul $v1, $v1, $a0
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

base_case:
    addi $v1, $zero, 1
    jr $ra
