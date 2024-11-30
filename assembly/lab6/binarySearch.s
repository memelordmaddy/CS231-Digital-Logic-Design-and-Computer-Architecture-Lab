.data 
    arr: .word 1, 2, 3, 4, 5,6, 7, 8
.text
main:
    la $a0, arr
    li $a1, 8
    li $a2, 0
    li $a3, 7
    li $s0, 4 
    jal binarySearch

    li $v0, 1
    move $a0, $v1
    syscall

    li $v0, 10
    syscall


binarySearch: #a0: A, a1:len(A), a2:start, a3:end, s0: val
    beq $a1, $zero, not_found
    add $t0, $a2, $a3 
    srl $t0, $t0, 1 # t0 has mid
    sll $t0, $t0, 2 # t0 has index now
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    add $t2, $a0, $t0
    lw $t2, 0($t2)
    srl $t0, $t0, 2 #t0 has mid
    beq $t2, $s0, found
    bgt $t2, $s0, left
    bgt $s0, $t2, right

not_found:
    li $v1, -1
    j exit

found:
    move $v1, $t0
    j exit

left:
    sub $a1, $t0, $a2
    move $a3, $t0
    jal binarySearch

right: 
    sub $a1, $a3, $t0
    addi $a2, $t0, 1
    jal binarySearch

exit: 
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra