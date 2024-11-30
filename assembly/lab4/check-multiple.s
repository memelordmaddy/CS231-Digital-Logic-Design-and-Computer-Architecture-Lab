.data 

.text 
#.globl main
main:
    addi $s0, $zero, 15
    addi $s1, $zero, 15
    div $s0, $s1
    mfhi $t0
    div $s1, $s0
    mfhi $t1
#    li $v0, 1
 #   move $a0, $t0
  #  syscall

    beq $t0, $zero, equal
    beq $t1, $zero, equal
    addi $s2, $zero, 0
    j exit
    equal: 
        addi $s2, $zero, 1
        j exit
    
    exit:
        li $v0, 1
        move $a0, $s2
        syscall

        li $v0, 10
        syscall