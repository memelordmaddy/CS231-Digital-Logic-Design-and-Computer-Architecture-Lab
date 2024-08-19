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
assign z1_1 = (neg_a ^ neg_b) ? z1_4 : (z1_3);
wire c1,c2;
rca_Nbit #(2) ins4(z0, z2, 1'b0, z1_2, c1);
rca_Nbit #(2) ins5(z1_2, z1_1, c1, z1, c2); // if(a==a_abs xor b==b_abs then z1 = z1_2-z1_1 else z1= z1_2+z1_1)
wire [3:0] term1, term2, term3;
assign term1= {2'b0, z0};
assign term2= {1'b0, z1, 1'b0};
assign term3= {z2, 2'b0};
wire [3:0] temp;
wire c3, c4;
rca_Nbit #(4) ins6(term1, term2, 1'b0, temp, c3);
rca_Nbit #(4) ins7(temp, term3, c3, Z, c4);
endmodule