.data 
    zero: .double 0.0
    doub: .double 4.20
.text
.globl main
main:
    l.d $f2, doub
    l.d $f0, zero # always use even reg for doubles 
    li $v0, 3
    add.d $f12, $f2, $f0
    syscall
    li $v0, 10
    syscall

