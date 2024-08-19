`timescale 1ns/1ps

module tb_cla_32bit;

parameter N = 32;     /*Change this to 16 if you want to test CLA 16-bit*/

// declare your signals as reg or wire
reg [N-1:0] a;
reg [N-1:0] b;
reg cin;
wire [N-1:0] S;
wire cout, Pout, Gout;

initial begin

// write the stimuli conditions
$monitor("a:%b b:%b cin:%b S:%b cout:%b Pout:%b Gout:%b", a, b, cin, S, cout, Pout, Gout);
a=232; b=3232; cin=0; #1;
a=2133; b=1211; cin=0; #1;
a=1212; b=23232; cin=1; #1;

end

CLA_32bit dut (.a(a), .b(b), .cin(cin), .sum(S), .cout(cout), .Pout(Pout), .Gout(Gout));


initial begin
    $dumpfile("cla_32bit.vcd");
    $dumpvars(0, tb_cla_32bit);
end

endmodule
