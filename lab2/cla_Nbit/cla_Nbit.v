module CLA_4bit(a, b, cin, sum, cout);
input [3:0] a, b;
input cin;
output wire [3:0] sum;
output wire cout;
wire d0, d1, d2, d3;
wire t0, t1, t2, t3;
wire c1, c2, c3;

assign t0 = a[0] ^ b[0];
assign d0 = a[0] & b[0];
assign t1 = a[1] ^ b[1];
assign d1 = a[1] & b[1];
assign t2 = a[2] ^ b[2];
assign d2 = a[2] & b[2];
assign t3 = a[3] ^ b[3];
assign d3 = a[3] & b[3];

assign c1= (t0 & cin) | d0;
assign c2= (t1 & ((t0 & cin) | d0)) | d1;
assign c3= (t2 & ((t1 & ((t0 & cin) | d0)) | d1)) | d2;
assign cout= (t3 & ((t2 & ((t1 & ((t0 & cin) | d0)) | d1)) | d2)) | d3;

assign sum[0] = t0 ^ cin;
assign sum[1] = t1 ^ c1;
assign sum[2] = t2 ^ c2;
assign sum[3] = t3 ^ c3;

endmodule

module CLA_4bit_P_G(a, b, cin, sum, P, G);
input [3:0] a, b;
input cin;
output wire [3:0] sum;
output wire P, G;
wire d0, d1, d2, d3;
wire t0, t1, t2, t3;
wire c1, c2, c3;
wire cout;

assign t0 = a[0] ^ b[0];
assign d0 = a[0] & b[0];
assign t1 = a[1] ^ b[1];
assign d1 = a[1] & b[1];
assign t2 = a[2] ^ b[2];
assign d2 = a[2] & b[2];
assign t3 = a[3] ^ b[3];
assign d3 = a[3] & b[3];

assign c1= (t0 & cin) | d0;
assign c2= (t1 & ((t0 & cin) | d0)) | d1;
assign c3= (t2 & ((t1 & ((t0 & cin) | d0)) | d1)) | d2;
assign cout= (t3 & ((t2 & ((t1 & ((t0 & cin) | d0)) | d1)) | d2)) | d3;

assign sum[0] = t0 ^ cin;
assign sum[1] = t1 ^ c1;
assign sum[2] = t2 ^ c2;
assign sum[3] = t3 ^ c3;

assign P = t0 & t1 & t2 & t3;
assign G = d3 | (t3 & d2) | (t3 & t2 & d1) | (t3 & t2 & t1 & d0);

endmodule

module lookahead_carry_unit_16_bit(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);
input P0, G0, P1, G1, P2, G2, P3, G3, cin;
output C4, C8, C12, C16, GF, PF;

assign C4 = G0 | (P0 & cin);
assign C8 = G1 | (P1 & C4);
assign C12 = G2 | (P2 & C8);
assign C16 = G3 | (P3 & C12);
assign PF = P0 & P1 & P2 & P3;
assign GF = G3 | (P3 & G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0);

endmodule

module CLA_16bit(a, b, cin, sum, cout, Pout, Gout);
input [15:0] a, b;
input cin;
output wire [15:0] sum;
output wire Pout, Gout, cout;

wire [3:0] s0, s1, s2, s3;
wire P0, G0, P1, G1, P2, G2, P3, G3;
wire c1, c2, c3, c4;

lookahead_carry_unit_16_bit ins69(P0, G0, P1, G1, P2, G2, P3, G3, cin, c1, c2, c3, c4, Gout, Pout);
CLA_4bit_P_G ins1(a[3:0], b[3:0], cin, s0, P0, G0);
CLA_4bit_P_G ins2(a[7:4], b[7:4], c1, s1, P1, G1);
CLA_4bit_P_G ins3(a[11:8], b[11:8], c2, s2, P2, G2);
CLA_4bit_P_G ins4(a[15:12], b[15:12], c3, s3, P3, G3);
assign cout = Gout | (Pout & c3);
assign sum = {s3, s2, s1, s0};
endmodule

module lookahead_carry_unit_32_bit (P0, G0, P1, G1, cin, C16, C32, GF, PF);
input P0, G0, P1, G1, cin;
output wire C16, C32, GF, PF;
assign C16 = G0 | (P0 & cin);
assign C32= G1 | (P1 & C16);
assign PF= P0 & P1;
assign GF= G1 | (P1 & G0);
endmodule

module CLA_32bit(a, b, cin, sum, cout, Pout, Gout);
input [31:0] a,b;
input cin;
output wire [31:0] sum;
output wire cout, Pout, Gout;
wire [15:0] s0, s1;
wire c1, c2;
wire P0, G0, P1, G1;
lookahead_carry_unit_32_bit ins1(P0, G0, P1, G1, cin, c1, c2, Pout, Gout);
CLA_16bit ins2(a[15:0], b[15:0], cin, s0, c1, P0, G0);
CLA_16bit ins3(a[31:16], b[31:16], c1, s1, c2, P1, G1);
assign cout = Gout | (Pout & c1);
assign sum= {s1,s0};
endmodule

