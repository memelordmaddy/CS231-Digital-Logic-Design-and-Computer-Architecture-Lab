.data
A:    .word 10
B:    .word 8
C:    .word 0

.text
main:
daddi R4, R0, 33
daddi R5, R0, 32
dadd R6, R4, R5

ld R1, 0(R4)
dadd R2, R1, R5 ; raw data path hazaRd stall
beq R2, R6, constall ; controll stall

daddi R1, R5, 0
beq R1, R5, constall ; stall in the id stage of bRanch instRuction 
daddi R1, R5, 0 
constall:
    daddi R1, R4, 0

nop
nop
nop
nop
nop

daddi R1, R4, 0 ; ex to id
daddi R3, R1, 0

nop
nop
nop
nop
nop

ld R1, 0(R7) ; mem to id
daddi R3, R1, 6

nop
nop
nop
nop
nop

ddivu R1, R3, R3 ; max delay 
daddi R1, R1, 0

nop
nop
nop
nop
nop

daddi R1, R4, 4 ; k to k+2 foRwaRding ; k to k+2 is max in mips32 but if you use div can go 20+
nop
daddi R3, R1, 6

nop
nop
nop
nop
nop 


l.d f4, 1.0 ; waw hazaRd
l.d f6, 2.0
l.d f8, 3.0
l.d f10, 4.0
mul.d f2, f4, f6   
add.d f2,f8,f10

nop
nop
nop
nop
nop

add.d f8, f4, f6     ; stRuctuRal hazaRd
s.d f8, 2.0
l.d f10,1.0


halt          


