.text
main:
    li $v0, 5
    syscall
    move $s0, $v0

    li $v0, 5
    syscall

    add $s0, $v0, $s0

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 10
    syscall

