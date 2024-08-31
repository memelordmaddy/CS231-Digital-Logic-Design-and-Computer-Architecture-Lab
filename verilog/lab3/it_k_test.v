/* 32-bit Karatsuba multiplication using a single 16-bit module */

module iterative_karatsuba_32_16(
    input clk,
    input rst,
    input enable,
    input [31:0] A,
    input [31:0] B,
    output [63:0] C
);
    
    wire [1:0] sel_x;
    wire [1:0] sel_y;
    wire [1:0] sel_z;
    wire [1:0] sel_T;
    wire done;
    wire en_z;
    wire en_T;
    wire [32:0] h1;
    wire [32:0] h2;
    wire [63:0] g1;
    wire [63:0] g2;
    
    assign C = g2;

    reg_with_enable #(.N(63)) Z (
        .clk(clk), 
        .rst(rst), 
        .en(en_z), 
        .X(g1), 
        .O(g2)
    );

    reg_with_enable #(.N(32)) T (
        .clk(clk), 
        .rst(rst), 
        .en(en_T), 
        .X(h1), 
        .O(h2)
    );
    
    iterative_karatsuba_datapath dp(
        .clk(clk), 
        .rst(rst), 
        .X(A), 
        .Y(B), 
        .Z(g2), 
        .T(h2), 
        .sel_x(sel_x), 
        .sel_y(sel_y), 
        .sel_z(sel_z), 
        .sel_T(sel_T), 
        .en_z(en_z), 
        .en_T(en_T), 
        .done(done), 
        .W1(g1), 
        .W2(h1)
    );

    iterative_karatsuba_control control(
        .clk(clk),
        .rst(rst), 
        .enable(enable), 
        .sel_x(sel_x), 
        .sel_y(sel_y), 
        .sel_z(sel_z), 
        .sel_T(sel_T), 
        .en_z(en_z), 
        .en_T(en_T), 
        .done(done)
    );
    
endmodule

module iterative_karatsuba_datapath(
    input clk,
    input rst,
    input [31:0] X,
    input [31:0] Y,
    input [32:0] T,
    input [63:0] Z,
    output reg [63:0] W1,
    output reg [32:0] W2,
    input [1:0] sel_x,
    input [1:0] sel_y,
    input en_z,
    input [1:0] sel_z,
    input en_T,
    input [1:0] sel_T,
    input done
);
    
    wire [15:0] mul_lhs, mul_rhs;
    wire [31:0] mul_res;

    
    mult_16 i1(.X(mul_lhs), .Y(mul_rhs), .Z(mul_res));

    
    assign mul_lhs = (sel_x == 2'b10) ? X[31:16] : 
                     (sel_x == 2'b01) ? X[15:0] : 
                     (sel_x == 2'b11) ? ((X[15:0] > X[31:16]) ? (X[15:0] - X[31:16]) : (X[31:16] - X[15:0])) : 
                     16'b0;


    assign mul_rhs = (sel_y == 2'b10) ? Y[31:16] : 
                     (sel_y == 2'b01) ? Y[15:0] : 
                     (sel_y == 2'b11) ? ((Y[15:0] > Y[31:16]) ? (Y[15:0] - Y[31:16]) : (Y[31:16] - Y[15:0])) : 
                     16'b0;

    wire cout;
    reg[63:0] add_operand;
    wire[63:0] z_op;
    adder_Nbit #(64) az(add_operand, Z, 1'b0, z_op, cout);
    always @(*) begin
        assign W1= z_op;
        if (en_z) begin
            case(sel_z)
                2'b01: add_operand= {32'b0, mul_res};   // Z += z0
                2'b10: add_operand= {mul_res, 32'b0};   // Z += z2
                2'b11: add_operand= {15'b0, T, 16'b0};  // Z += z1
                default: W1 = Z; 
            endcase
        end else begin
            W1 = 64'b0;
        end
        if (en_T) begin
        case(sel_T)
            2'b11: W2 = T + {1'b0, mul_res};  
            2'b10: W2 = ((X[15:0] > X[31:16]) ^ (Y[15:0] < Y[31:16])) ? (T + {1'b0, mul_res}) : (T - {1'b0, mul_res}); 
            default: W2 = 33'b0; 
        endcase
        end else begin
        W2 = 33'b0; 
    end

   
end

    
endmodule


module iterative_karatsuba_control(
    input clk,
    input rst,
    input enable,
    output reg [1:0] sel_x,
    output reg [1:0] sel_y,
    output reg [1:0] sel_z,
    output reg [1:0] sel_T,
    output reg en_z,
    output reg en_T,
    output reg done
);
    
    reg [5:0] state, nxt_state;

    parameter S0 = 6'b000001;
    parameter S1 = 6'b000010;
    parameter S2 = 6'b000100;
    parameter S3 = 6'b001000;
    parameter S4 = 6'b010000;
    parameter S5 = 6'b100000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state<= S0;
            nxt_state <= S0;
        end
        else if (enable) begin
            state <= nxt_state;
        end
    end
    
    always @(*) begin
       // $display(state);
    case(state)
        S0: begin
            sel_x <= 2'b00;
            sel_y <= 2'b00;
            sel_z <= 2'b00;
            sel_T <= 2'b11;
            en_z <= 1'b0;
            en_T<=1'b0;
            done <= 1'b0;
            nxt_state <= S1;
        end
        S1: begin
            sel_x <= 2'b10;
            sel_y <= 2'b10;
            sel_z <= 2'b10;
            en_z <= 1;
            en_T<=1;
            sel_T <= 2'b11;
            nxt_state <= S2;
        end
        S2: begin
            sel_x <= 2'b01;
            sel_y <= 2'b01;
            sel_z <= 2'b01;
            sel_T <= 2'b11;
            en_T<=1;
            en_z <=1;
            nxt_state <= S3;
        end
        S3: begin
            sel_x <= 2'b11;
            sel_y <= 2'b11;
            sel_z <= 2'b11;
            sel_T <= 2'b10;
            en_T<=1;
            en_z <=1;
            nxt_state <= S4;
        end
        S4: begin
            sel_z <=2'b00;
            en_z <=1;
            en_T <=0;
            done <=1;
            nxt_state <= S4;
        end
        default: begin
            nxt_state <= S0;
        end
    endcase
    end

endmodule



module reg_with_enable #(parameter N = 32) (
    input clk,
    input rst,
    input en,
    input [N:0] X,
    output [N:0] O
);
    
    reg [N:0] R;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R <= {(N+1){1'b0}};
        end else if (en) begin
            R <= X;
        end
    end

    assign O = R;
endmodule


/*------------- Iterative Karatsuba: 32-bit Karatsuba using a single 16-bit Module*/

module mult_16(X, Y, Z);
input [15:0] X;
input [15:0] Y;
output [31:0] Z;

assign Z = X*Y;

endmodule


module mult_17(X, Y, Z);
input [16:0] X;
input [16:0] Y;
output [33:0] Z;

assign Z = X*Y;

endmodule

module full_adder(a, b, cin, S, cout);
input a;
input b;
input cin;
output S;
output cout;

assign S = a ^ b ^ cin;
assign cout = (a&b) ^ (b&cin) ^ (a&cin);

endmodule


module check_subtract (A, B, C);
 input [7:0] A;
 input [7:0] B;
 output [8:0] C;
 
 assign C = A - B; 
endmodule



/* N-bit RCA adder (Unsigned) */
module adder_Nbit #(parameter N = 32) (a, b, cin, S, cout);
input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output cout;

wire [N:0] cr;  

assign cr[0] = cin;


generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin
        full_adder addi (.a(a[i]), .b(b[i]), .cin(cr[i]), .S(S[i]), .cout(cr[i+1]));
    end
endgenerate    


assign cout = cr[N];

endmodule


module Not_Nbit #(parameter N = 32) (a,c);
input [N-1:0] a;
output [N-1:0] c;

generate
genvar i;
for (i = 0; i < N; i = i+1) begin
    assign c[i] = ~a[i];
end
endgenerate 

endmodule


/* 2's Complement (N-bit) */
module Complement2_Nbit #(parameter N = 32) (a, c, cout_comp);

input [N-1:0] a;
output [N-1:0] c;
output cout_comp;

wire [N-1:0] b;
wire ccomp;

Not_Nbit #(.N(N)) compl(.a(a),.c(b));
adder_Nbit #(.N(N)) addc(.a(b), .b({ {N-1{1'b0}} ,1'b1 }), .cin(1'b0), .S(c), .cout(ccomp));

assign cout_comp = ccomp;

endmodule


/* N-bit Subtract (Unsigned) */
module subtract_Nbit #(parameter N = 32) (a, b, cin, S, ov, cout_sub);

input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output ov;
output cout_sub;

wire [N-1:0] minusb;
wire cout;
wire ccomp;

Complement2_Nbit #(.N(N)) compl(.a(b),.c(minusb), .cout_comp(ccomp));
adder_Nbit #(.N(N)) addc(.a(a), .b(minusb), .cin(1'b0), .S(S), .cout(cout));

assign ov = (~(a[N-1] ^ minusb[N-1])) & (a[N-1] ^ S[N-1]);
assign cout_sub = cout | ccomp;

endmodule



/* n-bit Left-shift */

module Left_barrel_Nbit #(parameter N = 32)(a, n, c);

input [N-1:0] a;
input [$clog2(N)-1:0] n;
output [N-1:0] c;


generate
genvar i;
for (i = 0; i < $clog2(N); i = i + 1 ) begin: stage
    localparam integer t = 2**i;
    wire [N-1:0] si;
    if (i == 0) 
    begin 
        assign si = n[i]? {a[N-t:0], {t{1'b0}}} : a;
    end    
    else begin 
        assign si = n[i]? {stage[i-1].si[N-t:0], {t{1'b0}}} : stage[i-1].si;
    end
end
endgenerate

assign c = stage[$clog2(N)-1].si;

endmodule