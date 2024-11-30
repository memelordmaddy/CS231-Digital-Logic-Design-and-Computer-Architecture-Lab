module half_adder(a, b, S, cout);
input a,b;
output wire S, cout;
assign S=a^b;
assign cout=a&b;
endmodule


module full_adder(a, b, cin, S, cout);
input a, b, cin;
output wire S, cout;
wire s1; wire cout1; wire cout2;
half_adder h1(.a(a), .b(b), .S(s1), .cout(cout1));
half_adder h2(.a(cin), .b(s1), .S(S), .cout(cout2));
assign cout= cout1|cout2;
endmodule

module rca_Nbit #(parameter N = 32) (a, b, cin, S, cout);
    input [N-1:0] a;
    input [N-1:0] b;
    input cin;
    wire carry[N:0];
    assign carry[0]=cin;
    output wire [N-1:0] S;
    output wire cout;
    generate 
        genvar i;
        for(i=0; i<N; i=i+1) begin
            full_adder fi(.a(a[i]), .b(b[i]), .cin(carry[i]), .S(S[i]), .cout(carry[i+1]));
        end
    endgenerate
    assign cout= carry[N];
endmodule


module subtractor_Nbit #(parameter N = 32) (a, b, cin, D, abs_D, negative);
    input [N-1:0] a;
    input [N-1:0] b;
    input cin; 
    output wire [N-1:0] D;   
    output wire [N-1:0] abs_D; 
    output wire negative;
    wire [N-1:0] b_comp; 
    wire [N:0] carry;
    wire is_pos;
    assign b_comp = ~b;
    assign carry[0] = cin;
    generate 
        genvar i;
        for (i = 0; i < N; i = i + 1) begin
            full_adder fi(.a(a[i]), .b(b_comp[i]), .cin(carry[i]), .S(D[i]), .cout(carry[i+1]));
        end
    endgenerate
    assign is_pos = carry[N];
    assign negative = ~is_pos;
    wire [N-1:0] twos;
    twos_compliment #(N) ins(D, twos);
    assign abs_D = is_pos ? D : twos;
endmodule

module twos_compliment #(parameter N=32) (input [N-1:0] i, output [N-1:0] o);
    wire [N-1:0] temp2;
    wire cout;
    assign temp2 = ~i;
    rca_Nbit #(N) rca_instance (temp2, {(N){1'b0}}, 1'b1, o, cout);
endmodule

module three_input_adder #(parameter N=32) (input [N-1:0] a, input [N-1:0] b, input [N:0] c, output [N:0] S);
wire [N-1:0] temp;
wire c1, c2;
rca_Nbit #(N) ins1(a, b, 1'b0, temp, c1);
wire [N:0] t_pad;
assign t_pad= (c1) ? {1'b1, temp} : {1'b0, temp};
rca_Nbit #(N+1) ins2(t_pad, c, 1'b0, S, c2);
endmodule

module karatsuba_1(input X, input Y, output[1:0] Z);
wire z= X & Y;
assign Z = {1'b0,z};
endmodule

module karatsuba_2(input [1:0] X, input [1:0] Y, output[3:0] Z);
wire [1:0] z2, z0, z1;
karatsuba_1 ins11(X[1], Y[1], z2);
karatsuba_1 ins12(X[0], Y[0], z0);
wire  a, b, a_abs, b_abs;
wire neg_a, neg_b;
subtractor_Nbit #(1) ins1(X[0], X[1], 1'b1, a, a_abs, neg_a);
subtractor_Nbit #(1) ins2(Y[1], Y[0], 1'b1, b, b_abs, neg_b);
wire [1:0] z1_1, z1_2, z1_3, z1_4;
karatsuba_1 ins3(a_abs, b_abs, z1_3);
twos_compliment #(2) ins69(z1_3, z1_4);
assign z1_1 = (neg_a ^ neg_b) ? z1_4 : z1_3;
wire c1,c2;
rca_Nbit #(2) ins4(z0, z2, 1'b0, z1_2, c1);
rca_Nbit #(2) ins5(z1_2, z1_1, c1, z1, c2); 
wire [3:0] term1, term2, term3;
assign term1= {2'b0, z0};
assign term2= {1'b0, z1, 1'b0};
assign term3= {z2, 2'b0};
wire [3:0] temp;
wire c3, c4;
rca_Nbit #(4) ins6(term1, term2, 1'b0, temp, c3);
rca_Nbit #(4) ins7(temp, term3, c3, Z, c4);
endmodule

module karatsuba_4(input [3:0] X, input [3:0] Y, output[7:0] Z);
wire [3:0] z2, z0, z1,  z1_2, z1_3;
wire [1:0] a, b, a_abs, b_abs;
wire neg_a, neg_b;
wire c1,c2, c3, c4;
wire [7:0] term1, term2, term3, temp;
karatsuba_2 ins11(X[3:2], Y[3:2], z2);
karatsuba_2 ins12(X[1:0], Y[1:0], z0);
subtractor_Nbit #(2) ins1(X[1:0], X[3:2], 1'b1, a, a_abs, neg_a);
subtractor_Nbit #(2) ins2(Y[3:2], Y[1:0], 1'b1, b, b_abs, neg_b);
karatsuba_2 ins3(a_abs, b_abs, z1_3);
wire [4:0] z1_3_pad, z1_1, z1_4;
assign z1_3_pad= {1'b0, z1_3};
twos_compliment #(5) ins69(z1_3_pad, z1_4);
assign z1_1 = (neg_a ^ neg_b) ? z1_4 : z1_3_pad;
wire [4:0] z1_pad;
three_input_adder #(4) ins32(z0, z2, z1_1, z1_pad);
assign term1= {4'b0, z0};
assign term2= {1'b0, z1_pad, 2'b0};
assign term3= {z2, 4'b0};
rca_Nbit #(8) ins6(term1, term2, 1'b0, temp, c3);
rca_Nbit #(8) ins7(temp, term3, 1'b0, Z, c4);
endmodule

module karatsuba_8(input [7:0] X, input [7:0] Y, output[15:0] Z);
wire [7:0]  z2, z0, z1,  z1_2, z1_3;
wire [3:0] a, b, a_abs, b_abs;
wire neg_a, neg_b;
wire c1,c2, c3, c4;
wire [15:0] term1, term2, term3, temp;
wire [8:0] z1_3_pad, z1_1, z1_4,z1_pad;
karatsuba_4 ins11(X[7:4], Y[7:4], z2);
karatsuba_4 ins12(X[3:0], Y[3:0], z0);
subtractor_Nbit #(4) ins1(X[3:0], X[7:4], 1'b1, a, a_abs, neg_a);
subtractor_Nbit #(4) ins2(Y[7:4], Y[3:0], 1'b1, b, b_abs, neg_b);
karatsuba_4 ins3(a_abs, b_abs, z1_3);
assign z1_3_pad= {1'b0, z1_3};
twos_compliment #(9) ins69(z1_3_pad, z1_4);
assign z1_1 = (neg_a ^ neg_b) ? z1_4 : z1_3_pad;
three_input_adder #(8) ins32(z0, z2, z1_1, z1_pad);
assign term1= {8'b0, z0};
assign term2= {3'b0, z1_pad, 4'b0};
assign term3= {z2, 8'b0};
rca_Nbit #(16) ins6(term1, term2, 1'b0, temp, c3);
rca_Nbit #(16) ins7(temp, term3, 1'b0, Z, c4);
endmodule

module karatsuba_16(input [15:0] X, input [15:0] Y, output[31:0] Z);
wire [15:0]  z2, z0, z1,  z1_2, z1_3;
wire [7:0] a, b, a_abs, b_abs;
wire neg_a, neg_b;
wire c1,c2, c3, c4;
wire [31:0] term1, term2, term3, temp;
wire [16:0] z1_3_pad, z1_1, z1_4,z1_pad;
karatsuba_8 ins11(X[15:8], Y[15:8], z2);
karatsuba_8 ins12(X[7:0], Y[7:0], z0);
subtractor_Nbit #(8) ins1(X[7:0], X[15:8], 1'b1, a, a_abs, neg_a);
subtractor_Nbit #(8) ins2(Y[15:8], Y[7:0], 1'b1, b, b_abs, neg_b);
karatsuba_8 ins3(a_abs, b_abs, z1_3);
assign z1_3_pad= {1'b0, z1_3};
twos_compliment #(17) ins69(z1_3_pad, z1_4);
assign z1_1 = (neg_a ^ neg_b) ? z1_4 : z1_3_pad;
three_input_adder #(16) ins32(z0, z2, z1_1, z1_pad);
assign term1= {16'b0, z0};
assign term2= {7'b0, z1_pad, 8'b0};
assign term3= {z2, 16'b0};
rca_Nbit #(32) ins6(term1, term2, 1'b0, temp, c3);
rca_Nbit #(32) ins7(temp, term3, 1'b0, Z, c4);
endmodule