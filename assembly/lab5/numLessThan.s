
.data
    prompt: .asciiz "Enter the real part of x "
    prompt1: .asciiz "Enter the imaginary part of x "
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
    addi $s0, $0, 2
    addi $t0, $t0, 4
    sw $s0, com($t0)
    

    addi $s0, $0, -1
    addi $t0, $t0, 4
    sw $s0, com($t0)
    addi $s0, $0, -1
    addi $t0, $t0, 4
    sw $s0, com($t0)



    li $v0, 4
    la $a0, prompt
    syscall
    li $v0, 5
    syscall
    move $s0, $v0

    li $v0, 4
    la $a0, prompt1
    syscall
    li $v0, 5
    syscall
    move $s1, $v0


    move $a0, $s0 #real of x
    move $a1, $s1 #imaginary of x

    addi $a2, $0, 0 #start
    addi $a3, $0, 4 #end

    la $t0, com
    addi $sp, $sp, -4
    sw $t0, 0($sp)

    jal numLessThan

    addi $sp, $sp, 4

    li $v0, 1
    move $a0, $v1
    syscall

    li $v0, 10
    syscall

isLessThan: # a0 = real x , a1= img x, a2= real a, a3= img a
    li $t2, 1
    slt $t3, $a2, $a0
    beq $t3, $t2, one
    beq $a0, $a2, check_again
    b zero

check_again:
    slt $t3, $a3, $a1
    beq $t3, $t1, one
    b zero

one:
    addi $v1, $v1, 1
    jr $ra

zero:
    jr $ra


numLessThan: #a0=real(x) a1= img(x) a2= start a3=end
    li $v1, 0
    lw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    sll $a2, $a2, 3
    sll $a3, $a3, 3
    forloop:
        beq $a2, $a3, exit
        addi $sp, $sp, -8
        sw $a2, 0($sp)
        sw $a3, 4($sp)
        add $t0, $t0, $a2
        lw $a2, 0($t0)
        addi $t0, $t0, 4
        lw $a3, 0($t0)
        jal isLessThan
        lw $a3, 4($sp)
        lw $a2, 0($sp)
        addi $sp, $sp, 8
        addi $a2, $a2, 8
        j forloop
    exit:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra



























