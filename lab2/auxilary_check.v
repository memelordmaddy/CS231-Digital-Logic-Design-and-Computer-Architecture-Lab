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

module tb_subtractor_Nbit();
    parameter N = 32;
    
    // Inputs
    reg [N-1:0] a, b;
    reg cin;

    // Outputs
    wire [N-1:0] D;
    wire [N-1:0] abs_D;

    // Instantiate the subtractor_Nbit module
    subtractor_Nbit #(N) uut (
        .a(a),
        .b(b),
        .cin(cin),
        .D(D),
        .abs_D(abs_D)
    );

    initial begin
        // Test case 1: a > b, positive result
        a = 32'h00000010; // 16
        b = 32'h00000008; // 8
        cin = 1'b1;
        #10;
        $display("Test 1: a = %h, b = %h, D = %h, abs_D = %h", a, b, D, abs_D);

        // Test case 2: a < b, negative result
        a = 32'h00000008; // 8
        b = 32'h00000010; // 16
        cin = 1'b1;
        #10;
        $display("Test 2: a = %h, b = %h, D = %h, abs_D = %h", a, b, D, abs_D);

        // Test case 3: a = b, zero result
        a = 32'h00000010; // 16
        b = 32'h00000010; // 16
        cin = 1'b1;
        #10;
        $display("Test 3: a = %h, b = %h, D = %h, abs_D = %h", a, b, D, abs_D);

        // Test case 4: a > b, with larger values
        a = 32'h12345678;
        b = 32'h00001234;
        cin = 1'b1;
        #10;
        $display("Test 4: a = %h, b = %h, D = %h, abs_D = %h", a, b, D, abs_D);

        // Test case 5: b > a, with larger values
        a = 32'h00001234;
        b = 32'h12345678;
        cin = 1'b1;
        #10;
        $display("Test 5: a = %h, b = %h, D = %h, abs_D = %h", a, b, D, abs_D);

        // Test case 6: Random values
        a = 32'hABCDEF01;
        b = 32'h12345678;
        cin = 1'b1;
        #10;
        $display("Test 6: a = %h, b = %h, D = %h, abs_D = %h", a, b, D, abs_D);

        $finish;
    end
endmodule
