module parity_bit_generator(input x,input y,input z,output reg o);
always @*
begin
    o= (x && y && z) || (!x && !y &&z) || (x &&! y && !z) || (!x && y &&!z);
end
endmodule

module testbench;
reg x,y,z;
integer i,j,k;
wire o;
parity_bit_generator a_instance(.x(x), .y(y),.z(z),.o(o));
initial begin
$dumpvars();
$display("23b1060: Madhav R Babu");
$monitor("x: %b y:%b z:%b o:%b", x, y,z,o);
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