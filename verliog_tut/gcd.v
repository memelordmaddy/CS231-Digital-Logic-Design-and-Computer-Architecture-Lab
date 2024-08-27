module gcd(input [3:0] x, input [3:0] y, output reg [3:0] g);
    reg [3:0] a, b;
    integer count;
    always @(*) begin
        a = x;
        b = y;
        count = 0;
        while (a != b) begin
            if (a[0] == 0 && b[0] == 0) begin
                a = a >> 1;
                b = b >> 1;
                count = count + 1;
            end
            else if (a[0] == 0 && b[0] == 1) begin
                a = a >> 1;
            end
            else if (b[0] == 0 && a[0] == 1) begin
                b = b >> 1;
            end
            else begin
                if (a >= b) begin
                    a = a - b;
                end else begin
                    b = b - a;
                end
            end
        end
        while (count > 0) begin
            a = a << 1;
            count = count - 1;
        end
        g = a;
    end
endmodule
module tb_gcd();
    reg[3:0] x, y;
    wire[3:0] g;
    gcd ins1(x, y, g);
    integer i=0;
    initial begin
        for(i=0; i<10; i= i+1) begin
        $monitor("x:%d, y:%d, gcd:%d", x, y, g);
        x= $random;
        y= $random;
        #1;
        end
    end
endmodule