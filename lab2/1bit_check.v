module tb_karatsuba_1();
    // Inputs
    reg X, Y;

    // Outputs
    wire [1:0] Z;

    // Instantiate the karatsuba_1 module
    karatsuba_1 uut (
        .X(X),
        .Y(Y),
        .Z(Z)
    );

    initial begin
        // Test case 1: X = 0, Y = 0
        X = 1'b0;
        Y = 1'b0;
        #10;
        $display("Test 1: X = %b, Y = %b, Z = %b", X, Y, Z);

        // Test case 2: X = 0, Y = 1
        X = 1'b0;
        Y = 1'b1;
        #10;
        $display("Test 2: X = %b, Y = %b, Z = %b", X, Y, Z);

        // Test case 3: X = 1, Y = 0
        X = 1'b1;
        Y = 1'b0;
        #10;
        $display("Test 3: X = %b, Y = %b, Z = %b", X, Y, Z);

        // Test case 4: X = 1, Y = 1
        X = 1'b1;
        Y = 1'b1;
        #10;
        $display("Test 4: X = %b, Y = %b, Z = %b", X, Y, Z);

        $finish;
    end
endmodule
