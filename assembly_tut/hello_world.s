.data
message: .asciiz "Hello World"

.text
.globl main
main:
    li $v0, 4
    la $a0, message
    syscall
    li $v0, 10
    syscall