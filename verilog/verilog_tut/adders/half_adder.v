module half_adder(input x, input y, output reg s, output reg c);
always @(x or y )
begin
     s= x^y;
    c=x & y;
end
endmodule
module tb;
reg x,y;
wire s, c;
integer i,j;
half_adder ha(.x(x), .y(y), .s(s), .c(c));
initial begin
    $monitor("x:%b y:%b sum:%b carry:%b", x, y, s,c);
    for(i=0; i<2; i=i+1) begin
        for(j=0; j<2; j=j+1)begin
            x<=i;
            y<=j;
            #2;
    end
    end
end
endmodule