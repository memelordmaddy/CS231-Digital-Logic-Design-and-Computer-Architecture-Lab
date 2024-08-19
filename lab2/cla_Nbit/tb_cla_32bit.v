`timescale 1ns/1ps

module tb_cla_32bit;

parameter N = 32;     /*Change this to 16 if you want to test CLA 16-bit*/

// declare your signals as reg or wire
reg [N-1:0] a;
reg [N-1:0] b;
reg cin;
wire [N-1:0] S;
reg [N-1:0] expected_sum;
wire cout, Pout, Gout;
integer i;
initial begin

// write the stimuli conditions
$monitor("a:%d b:%d cin:%d S:%d expected:%d", a, b, cin, S, expected_sum);
    for (i = 0; i < 10000; i = i + 1) 
        begin
            a = $random;
            b = $random;
            cin = $random % 2; 
            expected_sum= (a+b+cin);
            #1;
        end
end

CLA_32bit dut (.a(a), .b(b), .cin(cin), .sum(S), .cout(cout), .Pout(Pout), .Gout(Gout));

initial begin
    $dumpfile("cla_32bit.vcd");
    $dumpvars(0, tb_cla_32bit);
end

endmodule
