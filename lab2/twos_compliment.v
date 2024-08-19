module tb_twos_compliment;
    // Parameters
    parameter N = 32;

    // Testbench signals
    reg [N-1:0] i;
    wire [N-1:0] o;

    // Instantiate the two's complement module
    twos_compliment #(N) uut (
        .i(i),
        .o(o)
    );

    // Test procedure
    initial begin
        // Monitor changes
        $monitor("Time = %0t | i = %b | o = %b", $time, i, o);
        
        // Test case 1: Input = 0
        i = 32'b0;
        #10;
        // Expected output: 32'b1 (two's complement of 0 is 1)

        // Test case 2: Input = 1
        i = 32'b1;
        #10;
        // Expected output: 32'b11111111111111111111111111111111 (two's complement of 1 is -1)

        // Test case 3: Input = 10
        i = 32'b00000000000000000000000000001010;
        #10;
        // Expected output: 32'b11111111111111111111111111110110 (two's complement of 10 is -10)

        // Test case 4: Input = 255
        i = 32'b00000000000000000000000011111111;
        #10;
        // Expected output: 32'b11111111111111111111111100000001 (two's complement of 255 is -255)

        // Test case 5: Input = -1 (represented as all 1s)
        i = 32'b11111111111111111111111111111111;
        #10;
        // Expected output: 32'b00000000000000000000000000000001 (two's complement of -1 is 1)

        // End the simulation
        $finish;
    end
endmodule
