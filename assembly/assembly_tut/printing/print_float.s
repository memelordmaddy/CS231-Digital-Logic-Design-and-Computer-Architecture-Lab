.data 
    num: .float  4.20
.text
.globl main
main:
    li $v0, 2
    l.s $f12, num #lwcl ??
    syscall
    li $v0, 10
    syscall

