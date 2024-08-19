module tb_karatsuba_16;
    // Parameters
    parameter WIDTH = 16;

    // Testbench signals
    reg [WIDTH-1:0] X, Y;
    wire [2*WIDTH-1:0] Z;

    // Instantiate the Karatsuba multiplier module
    karatsuba_16 uut (
        .X(X),
        .Y(Y),
        .Z(Z)
    );
integer i, j;
    // Test procedure
    initial begin
        // Monitor changes
        $monitor("Time = %0t | X = %d | Y = %d | Z = %d", $time, X, Y, Z);

        // Loop through all test cases from 0 to 32
        
        for (i = 0; i <64; i = i + 1) begin
            for (j = 0; j <64; j = j + 1) begin
                // Apply values
                X = i;
                Y = j;
                #10;
                // Display the result
                $display("X = %d, Y = %d, Z = %d (Expected: %d)", X, Y, Z, X * Y);
            end
        end

        // End the simulation
        $finish;
    end
endmodule
