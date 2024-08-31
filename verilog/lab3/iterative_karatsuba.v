/* 32-bit simple karatsuba multiplier */

/*32-bit Karatsuba multipliction using a single 16-bit module*/

module iterative_karatsuba_32_16(clk, rst, enable, A, B, C); // done 
    input clk;
    input rst;
    input [31:0] A;
    input [31:0] B;
    output [63:0] C;
    
    input enable;
    
    
    wire [1:0] sel_x; // seleecting x1 and x0
    wire [1:0] sel_y; // selecting y1 and y0
    
    wire [1:0] sel_z; // 
    wire [1:0] sel_T; //
    
    
    wire done;
    wire en_z;
    wire en_T;
    
    
    wire [32:0] h1;
    wire [32:0] h2;
    wire [63:0] g1;
    wire [63:0] g2;
    
    assign C = g2;
    // g2 = 0 if reset g2= g1 if en_z 
    reg_with_enable #(.N(63)) Z(.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2) );  // Fill in the proper size of the register
    // h2= h1 if en_T enabled else 0
    reg_with_enable #(.N(63)) T(.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2) );  // Fill in the proper size of the register
    
    iterative_karatsuba_datapath dp(.clk(clk), .rst(rst), .X(A), .Y(B), .Z(g2), .T(h2), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done), .W1(g1), .W2(h1));
    iterative_karatsuba_control control(.clk(clk),.rst(rst), .enable(enable), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done));
    
endmodule

module iterative_karatsuba_datapath(clk, rst, X, Y, T, Z, sel_x, sel_y, en_z, sel_z, en_T, sel_T, done, W1, W2);
    input clk;
    input rst;
    input [31:0] X;    // input X
    input [31:0] Y;    // Input Y
    input [32:0] T;    // input which sums X_h*Y_h and X_l*Y_l (its also a feedback through the register)
    input [63:0] Z;    // input which calculates the final outcome (its also a feedback through the register)
    output [63:0] W1;  // Signals going to the registers as input
    output [32:0] W2;  // signals going to the registers as input
    

    input [1:0] sel_x;  // control signal 
    input [1:0] sel_y;  // control signal 
    
    input en_z;         // control signal 
    input [1:0] sel_z;  // control signal 
    input en_T;         // control signal 
    input [1:0] sel_T;  // control signal 
    
    input done;         // Final done signal
    
    
   
    
    //-------------------------------------------------------------------------------------------------
    
    // Write your datapath here
    wire [15:0] mul_lhs, mul_rhs;
    wire [31:0] mul_res;
    mult_16(mul_lhs, mul_rhs, mul_res);
    always @(X or Y or T or Z) begin
        case(sel_x)
            2'b10: mul_lhs<= X[31:16];
            2'b01: mul_lhs<= X[15:0];
            2'b11: mul_lhs<= X[15:0]-X[31:16]; // change 
            2'b00: mul_lhs<= {(N-1){1'b0}};
        endcase

        case(sel_y)
            2'b10: mul_rhs<= Y[31:16];
            2'b01: mul_rhs<= Y[15:0];
            2'b11: mul_rhs<= Y[15:0]-Y[31:16]; // change to absolute value
            2'b00: mul_rhs<= {(N-1){1'b0}};
        endcase
        
        case(en_z)
            2'b01: W1 <= Z + {32'b0, mul_res};
                    en_z <= 1'b1;  
            2'b10: W1 <= Z + {mul_res, 32'b0};
                    en_z <= 1'b1;
            2'b11: W1<= Z + {31'b0, T, 32'b0};
                    en_z<= 1'b1;
            2'b00:  en_z<=0; 
        endcase
        
        case(en_T)
            2'b11: W2<= T + {1'b0,mul_res};
                    en_T <=1'b1;
            2'b00: en_T <= 1'b0
            2'b01:
            2'b10:
        endcase
    end
    //--------------------------------------------------------

endmodule


module iterative_karatsuba_control(clk,rst, enable, sel_x, sel_y, sel_z, sel_T, en_z, en_T, done);
    input clk;
    input rst;
    input enable;
    
    output reg [1:0] sel_x;
    output reg [1:0] sel_y;
    
    output reg [1:0] sel_z;
    output reg [1:0] sel_T;    
    
    output reg en_z;
    output reg en_T;
    
    
    output reg done;
    
    reg [5:0] state, nxt_state; //ONE HOT ENCODE
    parameter S0 = 6'b000001;   // initial state
    parameter S1 = 6'b000010; 
    parameter S2 = 6'b000100; 
    parameter S3 = 6'b001000; 
    parameter S4 = 6'b010000; 
    parameter S5 = 6'b100000;     

    always @(posedge clk) begin
        if (rst) begin
            state <= S0;
        end
        else if (enable) begin
            state <= nxt_state;
        end
    end
    

    always@(*) begin
        case(state) 
            S1: 
                begin
                    nxt_state <= S2;
                    sel_x <= 2'b01;
                    sel_y <= 2'b01;
                    sel_z <= 2'b01;
                    sel_T <= 2'b11;
                end
			S2: 
                begin
                    nxt_state <= S3;
                    sel_x <= 2'b10;
                    sel_y <= 2'b10;
                    sel_z <= 2'b10;
                    sel_T <= 2'b11;
                end
            S3: 
                begin
                    nxt_state <= S4;
                    sel_x <= 2'b11;
                    sel_y <= 2'b11;
                    sel_z <= 2'b11;
                    sel_T <= 2'b11;
                end
            S4: localparams
                begin
                    nxt_state <= S5;
                    sel_x <= 2'b00;
                    sel_y <= 2'b00;
                    sel_z <= 2'b00;
                    sel_T <= 2'b00;
                    done <= 1'b1
                end

            S0: 
                begin
                    nxt_state <= S1;
                    sel_x <= 2'b00;
                    sel_y <= 2'b00;
                    sel_z <= 2'b00;
                    sel_T <= 2'b00;
                    done <= 1'b0;
                end
            default: 
                begin
                    nxt_state= S0;
                end            
        endcase 
    end
endmodule


module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O ); // if reset op=0 (N+1) bit, else op= ip (n+1) bit;
    input [N:0] X;
    input clk;
    input rst;
    input en;
    output [N:0] O;
    
    reg [N:0] R;
    
    always@(posedge clk) begin
        if (rst) begin
            R <= {N{1'b0}};
        end
        if (en) begin
            R <= X;
        end
    end
    assign O = R;
endmodule







/*-------------------Supporting Modules--------------------*/
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



