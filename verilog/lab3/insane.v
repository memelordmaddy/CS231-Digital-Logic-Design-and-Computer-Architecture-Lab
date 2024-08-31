module iterative_karatsuba_32_16(clk, rst, enable, A, B, C);
    input clk;
    input rst;
    input [31:0] A;
    input [31:0] B;
    output [63:0] C;
    input enable;

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

    // Set the output
    assign C = g2;

    // Instantiate registers with proper sizes
    reg_with_enable #(.N(64)) Z (.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2));
    reg_with_enable #(.N(33)) T (.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2));

    // Instantiate datapath and control modules
    iterative_karatsuba_datapath dp (
        .clk(clk), .rst(rst), .X(A), .Y(B), .T(h2), .Z(g2),
        .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T),
        .en_z(en_z), .en_T(en_T), .done(done), .W1(g1), .W2(h1)
    );

    iterative_karatsuba_control control (
        .clk(clk), .rst(rst), .enable(enable), .sel_x(sel_x), .sel_y(sel_y),
        .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done)
    );
endmodule


module iterative_karatsuba_datapath(
    input clk,
    input rst,
    input [31:0] X,
    input [31:0] Y,
    input [32:0] T,
    input [63:0] Z,
    output [63:0] W1,
    output [32:0] W2,
    input [1:0] sel_x,
    input [1:0] sel_y,
    input [1:0] sel_z,
    input [1:0] sel_T,
    input en_z,
    input en_T,
    input done
);
    wire [15:0] X_l16, X_h16, Y_l16, Y_h16;
    wire [31:0] M1, M2;
    wire [33:0] M3;
    wire [63:0] temp1, temp2;

    // Split 32-bit inputs into 16-bit halves
    assign X_l16 = X[15:0];
    assign X_h16 = X[31:16];
    assign Y_l16 = Y[15:0];
    assign Y_h16 = Y[31:16];

    // Compute partial products
    mult_16 mult1 (.X(X_l16), .Y(Y_l16), .Z(M1));
    mult_16 mult2 (.X(X_h16), .Y(Y_h16), .Z(M2));
    mult_17 mult3 (.X({X_l16, 1'b0}), .Y({Y_l16, 1'b0}), .Z(M3));

    // Combine partial products
    assign temp1 = M1 + (M3 << 16);
    assign W1 = temp1 + M2;
    assign W2 = T; // T is used to store intermediate results

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

    // Define states
    parameter S0 = 6'b000001;  // Initial state
    parameter S1 = 6'b000010;  // Example state for processing
    parameter S2 = 6'b000100;  // Example state for finalizing
    parameter S3 = 6'b001000;  // Example state for done

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0;
        end else if (enable) begin
            state <= nxt_state;
        end
    end

    always @(*) begin
        case(state)
            S0: begin
                // Initialize signals
                sel_x = 2'b00;
                sel_y = 2'b00;
                sel_z = 2'b00;
                sel_T = 2'b00;
                en_z = 1'b0;
                en_T = 1'b0;
                done = 1'b0;
                nxt_state = S1; // Transition to next state
            end
            S1: begin
                // Configure signals for partial product computation
                sel_x = 2'b01;  // Select lower half of X
                sel_y = 2'b01;  // Select lower half of Y
                sel_z = 2'b00;  // Use Z for intermediate storage
                sel_T = 2'b00;  // Use T for intermediate storage
                en_z = 1'b1;    // Enable Z register
                en_T = 1'b0;    // Disable T register
                done = 1'b0;
                nxt_state = S2; // Transition to the next state
            end
            S2: begin
                // Configure signals for the second partial product computation
                sel_x = 2'b10;  // Select higher half of X
                sel_y = 2'b10;  // Select higher half of Y
                sel_z = 2'b01;  // Store results in Z
                sel_T = 2'b01;  // Update T
                en_z = 1'b1;    // Enable Z register
                en_T = 1'b1;    // Enable T register
                done = 1'b0;
                nxt_state = S3; // Transition to the final state
            end
            S3: begin
                // Final state
                sel_x = 2'b00;
                sel_y = 2'b00;
                sel_z = 2'b00;
                sel_T = 2'b00;
                en_z = 1'b0;
                en_T = 1'b0;
                done = 1'b1;    // Indicate completion
                nxt_state = S0; // Return to initial state
            end
            default: begin
                // Default case
                sel_x = 2'b00;
                sel_y = 2'b00;
                sel_z = 2'b00;
                sel_T = 2'b00;
                en_z = 1'b0;
                en_T = 1'b0;
                done = 1'b0;
                nxt_state = S0;
            end
        endcase
    end
endmodule

module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O);
    input [N-1:0] X;
    input clk;
    input rst;
    input en;
    output [N-1:0] O;
    
    reg [N-1:0] R;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R <= {N{1'b0}};
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