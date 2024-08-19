module half_adder(a, b, S, cout);
input a,b;
output wire S, cout;
assign S=a^b;
assign cout=a && b;
endmodule


module full_adder(a, b, cin, S, cout);
input a, b, cin;
output wire S, cout;
wire s1; wire cout1; wire cout2;
half_adder h1(.a(a), .b(b), .S(s1), .cout(cout1));
half_adder h2(.a(cin), .b(s1), .S(S), .cout(cout2));
assign cout= cout1||cout2;
endmodule

module rca_Nbit #(parameter N = 32) (a, b, cin, S, cout);
    input [N-1:0] a;
    input [N-1:0] b;
    input [1:0]cin;
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
    assign cout= carry[N-1];
endmodule

module subtractor_Nbit #(parameter N = 32) (a, b, cin, D, abs_D);
    input [N-1:0] a;
    input [N-1:0] b;
    input cin; 
    output wire [N-1:0] D;   
    output wire [N-1:0] abs_D; 
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
    assign abs_D = is_pos ? D : ~D + 1;
endmodule

module karatsuba_16(input [15:0] X, input [15:0] Y, output[31:0] Z);
wire [15:0] z2, z0, z1;
karatsuba_8 ins11(X[15:8], Y[15:8], z2);
karatsuba_8 ins12(X[7:0], Y[7:0], z0);
wire [7:0] a, b, a_abs, b_abs;
subtractor_Nbit #(8) ins1(X[7:0], X[15:8], 1'b1, a, a_abs);
subtractor_Nbit #(8) ins2(Y[7:0], Y[15:8], 1'b1, b, b_abs);
wire [15:0] z1_1, z1_2;
karatsuba_8 ins3(a_abs, b_abs, z1_1);
wire c1,c2;
rca_Nbit #(16) ins4(z0, z1, 1'b0, z1_2, c1);
rca_Nbit #(16) ins5(z1_2, z1_1, c1, z1, c2);
wire [31:0] term1, term2, term3;
assign term1= {16'b0, z0};
assign term2= {8'b0, z1, 8'b0};
assign term3= {z2, 16'b0};
wire [31:0] temp;
wire c3, c4;
rca_Nbit #(32) ins6(term1, term2, 1'b0, temp, c3);
rca_Nbit #(32) ins7(temp, term3, c3, Z, c4);
endmodule