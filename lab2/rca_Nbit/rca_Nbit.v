module half_adder(a, b, S, cout);
input a,b;
output wire S, cout;
assign S=a^b;
assign cout=a&&b;
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

