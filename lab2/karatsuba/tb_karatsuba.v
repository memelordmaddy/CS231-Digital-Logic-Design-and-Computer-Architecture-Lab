module tb_karatsuba_16;
    parameter l = 16;
    reg [l-1:0] X, Y;
    wire [2*l-1:0] Z;
    karatsuba_16 ins1(X,Y,Z);
    integer i;
    reg [31:0] expected;
    initial begin
        $monitor(" X = %d | Y = %d | Z = %d | Expected = %d", X, Y, Z, expected);
        for (i = 0; i < 10000; i = i + 1) begin
            X = $random % (2**16);
            Y = $random % (2**16);
            expected = X * Y;
            #1;
            $display("X = %d, Y = %d, Z = %d (Expected: %d)", X, Y, Z, expected);
        end
        $finish;
    end
endmodule
