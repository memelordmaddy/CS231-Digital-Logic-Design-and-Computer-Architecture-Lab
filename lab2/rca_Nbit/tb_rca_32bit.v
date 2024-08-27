`timescale 1ns/1ps
module tb_rca_32_bit;
parameter N = 32;
// declare your signals as reg or wire
integer i;
reg [N-1:0] expected;
reg[N-1:0] A; reg[N-1:0] B; reg cin; wire[N-1:0] S; 
wire cout;
initial begin	
$monitor("A:%d, B:%d, cin:%d, Sum:%d, Expected:%d", A, B, cin, S, expected);
// write the stimuli conditions\
for(i=0; i<1000; i=i+1) begin
    A= $random;
    B=$random;
    cin= $random%2;
    expected = A+B+cin;
    #1;
end
end
rca_Nbit #(32) dut(.a(A), .b(B), .cin(cin), .S(S), .cout(cout));

initial begin
    $dumpfile("rca_32bit.vcd");
    $dumpvars(0, tb_rca_32_bit);
end
endmodule
