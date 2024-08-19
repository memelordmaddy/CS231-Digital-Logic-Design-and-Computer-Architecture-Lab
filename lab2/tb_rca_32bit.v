`timescale 1ns/1ps
module tb_rca_32_bit;
parameter N = 32;
// declare your signals as reg or wire
reg[N-1:0] A; reg[N-1:0] B; reg[1:0] cin; wire[N-1:0] S; wire cout;
initial begin	
// write the stimuli conditions\
A= 48; B= 69;  cin= 1'b0; 

 $monitor("A:%b B:%b C:%b S:%b cout:%b", A, B,cin, S, cout);
end
rca_Nbit #(32) dut(.a(A), .b(B), .cin(cin), .S(S), .cout(cout));

initial begin
    $dumpfile("rca_32bit.vcd");
    $dumpvars(0, tb_rca_32_bit);
end
endmodule
