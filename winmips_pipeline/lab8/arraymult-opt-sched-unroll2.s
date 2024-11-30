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
    mul.d F10, F6, F1 
    l.d F8, d(R2)        
    l.d F14, a+8(R2)        
    l.d F16, b+8(R2)
    add.d F12, F8, F10  #slight stall here           
    mul.d F18, F14, F16
    mul.d F22, F18, F1
    s.d F12, d(R2)  
    l.d F20, d+8(R2)
    s.d F18, c+8(R2)        
    add.d F24, F20, F22   #slight stall here  
    s.d F24, d+8(R2)
    s.d F6, c(R2)        
    daddi R2, R2, 16        
    bne R1, R2, loop        
exit:
    halt

    