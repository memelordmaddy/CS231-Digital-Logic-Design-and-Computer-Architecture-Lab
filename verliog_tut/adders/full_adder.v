module full_adder(
    input x, 
    input y, 
    input z, 
    output wire s, 
    output wire c
);

// Internal signals for half adder outputs
wire s1;
wire c1;
wire c2;

// Instantiate the first half-adder
half_adder h1(
    .x(x), 
    .y(y), 
    .s(s1), 
    .c(c1)
);

// Instantiate the second half-adder
half_adder h2(
    .x(z), 
    .y(s1), 
    .s(s), 
    .c(c2)
);

// Compute the final carry-out
assign c = c1 || c2;

endmodule
/*
module testbench;
reg x,y,z;
integer i,j,k;
wire s,c;
full_adder a_instance(.x(x), .y(y),.z(z),.s(s), .c(c));
initial begin
$monitor("x: %b y:%b z:%b sum:%b carry:%b", x, y,z,s,c);
x=0; y=0; z=0; #1;
for(i=0; i<2; i=i+1) begin
    for(j=0; j<2; j=j+1) begin
        for(k=0; k<2; k=k+1) begin
            
                x=i; y=j; z=k; 
                #1;

            end
        end
    end
end
endmodule
*/