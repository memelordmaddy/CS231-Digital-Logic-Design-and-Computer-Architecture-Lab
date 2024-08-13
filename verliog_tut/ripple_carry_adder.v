module ripple_4_bit(input wire[3:0] A, input wire [3:0] B, input wire c_f, output wire[3:0] C, output wire c_out);
wire c1, c2, c3;
full_adder f0(.x(A[0]), .y(B[0]), .z(c_f), .s(C[0]), .c(c1));
full_adder f1(.x(A[1]), .y(B[1]), .z(c1), .s(C[1]), .c(c2));
full_adder f2(.x(A[2]), .y(B[2]), .z(c2), .s(C[2]), .c(c3));
full_adder f3(.x(A[3]), .y(B[3]), .z(c3), .s(C[3]), .c(c_out));
endmodule


module tb_ripple_4_bit;

    // Inputs
    reg [3:0] A;
    reg [3:0] B;
    reg c_f;

    // Outputs
    wire [3:0] C;
    wire c_out;

    // Instantiate the Unit Under Test (UUT)
    ripple_4_bit uut (
        .A(A), 
        .B(B), 
        .c_f(c_f), 
        .C(C), 
        .c_out(c_out)
    );

    initial begin
        // Initialize Inputs
        A = 4'b0000;
        B = 4'b0000;
        c_f = 0;

        // Apply test vectors
        #10 A = 4'b0001; B = 4'b0001; c_f = 0;
        #10 A = 4'b0010; B = 4'b0011; c_f = 0;
        #10 A = 4'b0110; B = 4'b0101; c_f = 1;
        #10 A = 4'b1111; B = 4'b1111; c_f = 1;

        // Add more test cases as needed
        // Example of additional test cases
        #10 A = 4'b0101; B = 4'b0011; c_f = 0;
        #10 A = 4'b1001; B = 4'b1001; c_f = 0;
        #10 A = 4'b0110; B = 4'b1000; c_f = 1;
        #10 A = 4'b1010; B = 4'b0101; c_f = 1;

        // Finish the simulation
        #10 $finish;
    end

    // Monitor changes
    initial begin
        $monitor("At time %t: A = %b, B = %b, c_f = %b -> C = %b, c_out = %b", 
                 $time, A, B, c_f, C, c_out);
    end

endmodule
