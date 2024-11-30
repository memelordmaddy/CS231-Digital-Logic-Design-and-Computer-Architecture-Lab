module gcd(x, y, clk, reset, gcd );
input reg clk, rst;
input reg [15:0] x,y;
reg[15:0] x_reg, y_reg;
x_reg= x;
y_reg=y;
output wire [15:0] gcd;
reg [2:0] cs, ns;
parameter A:2'b000;
parameter B:2'b001;
parameter C:2'b010;
parameter D:2'b011;
parameter E:2'b100;
parameter F:2'b101;
parameter G:2'b110;
always @(posedge clk or posedge rst)
begin 
    if(rst) begin
        cs <= A;
    end
    else begin
        cs <= ns;
    end
end
always @(control or cs)
begin
    case(cs)
        A: begin 
            if(x_reg[0]==0 & y_reg[0]==0)begin
                ns <=A;
                x_reg <= {1'b0, x_reg[15:1]};
                y_reg <= {1'b0, Y_reg[15:1]};
            end
            else if begin
                
            end 
            
            end
    endcase
end
endmodule