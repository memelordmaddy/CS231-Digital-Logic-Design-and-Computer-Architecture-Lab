.data 
a: .double  1.0, 2.0, 3.0, 4.0, 5.0, 6.0
b: .double  2.0, 3.0, 4.0, 5.0, 6.0, 7.0
c: .double  0.0, 0.0, 0.0, 0.0, 0.0, 0.0
d: .double  0.0, 0.0, 0.0, 0.0, 0.0, 0.0
alpha: .double 10.0

.text
main:
    daddi R1, R0, 48       # n=6 in r1
    l.d F1, alpha($zero)      # f1= alpha
    daddi R2, R0, 0       # i in r2

loop:
    l.d F2, a(R2)           
    l.d F4, b(R2)           
    mul.d F6, F2, F4       
    s.d F6, c(R2)           # this is dependent on f6 this stall can't be avoided
    mul.d F8, F6, F1        #this also needs f6
    l.d F10, d(R2)          
    add.d F10, F10, F8     
    s.d F10, d(R2)          # this needs f10    
    daddi R2, R2, 8                           
    bne R1, R2, loop
exit:
    halt

    