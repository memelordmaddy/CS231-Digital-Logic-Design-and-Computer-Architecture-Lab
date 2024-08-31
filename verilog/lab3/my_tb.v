module tb_iterative_karatsuba_32_16;

    // Testbench signals
    reg clk;
    reg rst;
    reg enable;
    reg [31:0] A;
    reg [31:0] B;
    wire [63:0] C;

    // Instantiate the Unit Under Test (UUT)
    iterative_karatsuba_32_16 uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .A(A),
        .B(B),
        .C(C)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        enable = 0;
        A = 32'h00000000;
        B = 32'h00000000;

        // Apply reset
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Test case 1
        enable = 1;
        A = 32'h00000012; // Arbitrary test values
        B = 32'h00000034;
        #10;
        
        // Add more test cases here
        // Example Test Case 2
        A = 32'h000000AB; // Another test value
        B = 32'h000000CD;
        #10;

        // Disable after test
        enable = 0;
        #20;

        // End simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %0t: A = %h, B = %h, C = %h", $time, A, B, C);
    end

endmodule
