/* 32-bit simple karatsuba multiplier */

module simple_karatsuba #(parameter N = 32) (X, Y, Z);
    input [N-1:0] X;
    input [N-1:0] Y;
    output [(2*N -1):0] Z;
    
    wire [(N/2)-1:0] X_h;
    wire [(N/2)-1:0] X_l;
    
    wire [(N/2)-1:0] Y_h;
    wire [(N/2)-1:0] Y_l;    
    
    wire [N-1:0] t0;
    wire [N-1:0] t2;
    
    
    wire [N:0] t1;
    wire [N-1:0] t11;
    wire [N:0] t12;

    wire [(N/2)-1:0] Xh_P_Xl;
    wire [(N/2)-1:0] Yh_P_Yl;
    
    wire [(N/2)-1:0] Xh_P_Xl_tmp;
    wire [(N/2)-1:0] Yh_P_Yl_tmp;
    
    wire [(N/2)-1:0] comp_Xh_P_Xl;
    wire [(N/2)-1:0] comp_Yh_P_Yl;    
    
    
    wire [N-1:0] comp_t11;
    wire [N-1:0] t11_tmp;

    wire cin1;
    wire cin2;
    
    wire ov1;
    wire ob2;
    
    wire cout_sub1;
    wire cout_sub2;
    
    assign X_h = X[N-1:(N/2)];
    assign X_l = X[(N/2)-1:0];
    
    assign Y_h = Y[N-1:(N/2)];
    assign Y_l = Y[(N/2)-1:0];
    
    assign t2 = X_h * Y_h;  //z_h = x_h * y_h ; N/2-bit multiplier
    assign t0 = X_l * Y_l;  //z_l = x_l * y_l ; N/2-bit multiplier 
    
    //Calculate z_m = x_h*y_l + x_l*y_h using Karatsuba's trick (the subtraction trick is used to use the N/2 bit multipliers only)
    
    assign cin1 = 0;
    assign cin2 = 0;
    subtract_Nbit #(.N(N/2)) sub1 (.a(X_l), .b(X_h), .cin(cin1), .S(Xh_P_Xl_tmp), .ov(ov1), .cout_sub(cout_sub1));  // N/2-bit subtractor with (N/2)-bit result
    subtract_Nbit #(.N(N/2)) sub2 (.a(Y_h), .b(Y_l), .cin(cin2), .S(Yh_P_Yl_tmp), .ov(ov2), .cout_sub(cout_sub2));  // N/2-bit subtractor with (N/2)-bit result
    
    // Take the absolute values for multiplication
    Complement2_Nbit #(.N(N/2)) comp1 (.a(Xh_P_Xl_tmp), .c(comp_Xh_P_Xl), .cout_comp());
    Complement2_Nbit #(.N(N/2)) comp2 (.a(Yh_P_Yl_tmp), .c(comp_Yh_P_Yl), .cout_comp());
    assign Xh_P_Xl = cout_sub1 ? Xh_P_Xl_tmp: comp_Xh_P_Xl;
    assign Yh_P_Yl = cout_sub2 ? Yh_P_Yl_tmp: comp_Yh_P_Yl;


    assign t11_tmp = (Xh_P_Xl * Yh_P_Yl);   // N/2-bit multiplication

    assign t12 = t0 + t2;    // N-bit addition with N+1 bit output
    
    // Now determine the sign of the multiplied value. Depending on this sign we perfrom addition or subtraction (with carry)
    wire select;
    assign select = cout_sub1 ^ cout_sub2;
    assign t1 = select? (t12 - t11_tmp) : (t12 + t11_tmp);
    
    assign Z = (t2 << N) + (t1 << (N/2)) + t0;

    
endmodule


module simp_mult #(parameter N = 32) (X, Y, Z);
    input [N-1:0] X;
    input [N-1:0] Y;
    output [(2*N -1):0] Z;

    assign Z = X*Y;
endmodule


module recursive_karatsuba_16 (X, Y, Z);

    input [16-1:0] X;
    input [16-1:0] Y;
    output [(2*16 -1):0] Z;
    
    wire [(16/2)-1:0] X_h;
    wire [(16/2)-1:0] X_l;
    
    wire [(16/2)-1:0] Y_h;
    wire [(16/2)-1:0] Y_l;    
    
    wire [16-1:0] t0;
    wire [16-1:0] t2;
    
    
    wire [16:0] t1;
    wire [16-1:0] t11;
    wire [16:0] t12;

    wire [(16/2)-1:0] Xh_P_Xl;
    wire [(16/2)-1:0] Yh_P_Yl;
    
    wire [(16/2)-1:0] Xh_P_Xl_tmp;
    wire [(16/2)-1:0] Yh_P_Yl_tmp;
    
    wire [(16/2)-1:0] comp_Xh_P_Xl;
    wire [(16/2)-1:0] comp_Yh_P_Yl;    
    
    
    wire [16-1:0] comp_t11;
    wire [16-1:0] t11_tmp;

    wire cin1;
    wire cin2;
    
    wire ov1;
    wire ob2;
    
    wire cout_sub1;
    wire cout_sub2;
    
    assign X_h = X[16-1:(16/2)];
    assign X_l = X[(16/2)-1:0];
    
    assign Y_h = Y[16-1:(16/2)];
    assign Y_l = Y[(16/2)-1:0];

    recursive_karatsuba_8 mult1 (.X(X_h), .Y(Y_h), .Z(t2));
    recursive_karatsuba_8 mult2 (.X(X_l), .Y(Y_l), .Z(t0));    
    
    //Calculate z_m = x_h*y_l + x_l*y_h using Karatsuba's trick (the subtraction trick is used to use the N/2 bit multipliers only)
    
    assign cin1 = 0;
    assign cin2 = 0;
    subtract_Nbit #(.N(16/2)) sub1 (.a(X_l), .b(X_h), .cin(cin1), .S(Xh_P_Xl_tmp), .ov(ov1), .cout_sub(cout_sub1));  // N/2-bit subtractor with (N/2)-bit result
    subtract_Nbit #(.N(16/2)) sub2 (.a(Y_h), .b(Y_l), .cin(cin2), .S(Yh_P_Yl_tmp), .ov(ov2), .cout_sub(cout_sub2));  // N/2-bit subtractor with (N/2)-bit result
    
    // Take the absolute values for multiplication
    Complement2_Nbit #(.N(16/2)) comp1 (.a(Xh_P_Xl_tmp), .c(comp_Xh_P_Xl), .cout_comp());
    Complement2_Nbit #(.N(16/2)) comp2 (.a(Yh_P_Yl_tmp), .c(comp_Yh_P_Yl), .cout_comp());
    assign Xh_P_Xl = cout_sub1 ? Xh_P_Xl_tmp: comp_Xh_P_Xl;
    assign Yh_P_Yl = cout_sub2 ? Yh_P_Yl_tmp: comp_Yh_P_Yl;

    recursive_karatsuba_8 mult3 (.X(Xh_P_Xl), .Y(Yh_P_Yl), .Z(t11_tmp));

    assign t12 = t0 + t2;    // N-bit addition with N+1 bit output
    
    // Now determine the sign of the multiplied value. Depending on this sign we perfrom addition or subtraction (with carry)
    wire select;
    assign select = cout_sub1 ^ cout_sub2;
    assign t1 = select? (t12 - t11_tmp) : (t12 + t11_tmp);
    
    
    
    assign Z = (t2 << 16) + (t1 << (16/2)) + t0;

endmodule


/* 8-bit recursive karatsuba multiplier */

module recursive_karatsuba_8(X, Y, Z);
    input [8-1:0] X;
    input [8-1:0] Y;
    output [(2*8 -1):0] Z;
    
    wire [(8/2)-1:0] X_h;
    wire [(8/2)-1:0] X_l;
    
    wire [(8/2)-1:0] Y_h;
    wire [(8/2)-1:0] Y_l;    
    
    wire [8-1:0] t0;
    wire [8-1:0] t2;
    
    
    wire [8:0] t1;
    wire [8-1:0] t11;
    wire [8:0] t12;

    wire [(8/2)-1:0] Xh_P_Xl;
    wire [(8/2)-1:0] Yh_P_Yl;
    
    wire [(8/2)-1:0] Xh_P_Xl_tmp;
    wire [(8/2)-1:0] Yh_P_Yl_tmp;
    
    wire [(8/2)-1:0] comp_Xh_P_Xl;
    wire [(8/2)-1:0] comp_Yh_P_Yl;    
    
    
    wire [8-1:0] comp_t11;
    wire [8-1:0] t11_tmp;

    wire cin1;
    wire cin2;
    
    wire ov1;
    wire ob2;
    
    wire cout_sub1;
    wire cout_sub2;
    
    assign X_h = X[8-1:(8/2)];
    assign X_l = X[(8/2)-1:0];
    
    assign Y_h = Y[8-1:(8/2)];
    assign Y_l = Y[(8/2)-1:0];
    
    
    recursive_karatsuba_4 mult1 (.X(X_h), .Y(Y_h), .Z(t2));
    recursive_karatsuba_4 mult2 (.X(X_l), .Y(Y_l), .Z(t0));
    
    //Calculate z_m = x_h*y_l + x_l*y_h using Karatsuba's trick (the subtraction trick is used to use the N/2 bit multipliers only)
    
    assign cin1 = 0;
    assign cin2 = 0;
    subtract_Nbit #(.N(8/2)) sub1 (.a(X_l), .b(X_h), .cin(cin1), .S(Xh_P_Xl_tmp), .ov(ov1), .cout_sub(cout_sub1));  // N/2-bit subtractor with (N/2)-bit result
    subtract_Nbit #(.N(8/2)) sub2 (.a(Y_h), .b(Y_l), .cin(cin2), .S(Yh_P_Yl_tmp), .ov(ov2), .cout_sub(cout_sub2));  // N/2-bit subtractor with (N/2)-bit result
    
    // Take the absolute values for multiplication
    Complement2_Nbit #(.N(8/2)) comp1 (.a(Xh_P_Xl_tmp), .c(comp_Xh_P_Xl), .cout_comp());
    Complement2_Nbit #(.N(8/2)) comp2 (.a(Yh_P_Yl_tmp), .c(comp_Yh_P_Yl), .cout_comp());
    assign Xh_P_Xl = cout_sub1 ? Xh_P_Xl_tmp: comp_Xh_P_Xl;
    assign Yh_P_Yl = cout_sub2 ? Yh_P_Yl_tmp: comp_Yh_P_Yl;


    recursive_karatsuba_4 mult3 (.X(Xh_P_Xl), .Y(Yh_P_Yl), .Z(t11_tmp));
    
    
    assign t12 = t0 + t2;    // N-bit addition with N+1 bit output
    
    // Now determine the sign of the multiplied value. Depending on this sign we perfrom addition or subtraction (with carry)
    wire select;
    assign select = cout_sub1 ^ cout_sub2;
    assign t1 = select? (t12 - t11_tmp) : (t12 + t11_tmp);
  
    assign Z = (t2 << 8) + (t1 << (8/2)) + t0;

endmodule


module recursive_karatsuba_4(X, Y, Z);
    input [4-1:0] X;
    input [4-1:0] Y;
    output [(2*4 -1):0] Z;
    
    wire [(4/2)-1:0] X_h;
    wire [(4/2)-1:0] X_l;
    
    wire [(4/2)-1:0] Y_h;
    wire [(4/2)-1:0] Y_l;    
    
    wire [4-1:0] t0;
    wire [4-1:0] t2;
    
    
    wire [4:0] t1;
    wire [4-1:0] t11;
    wire [4:0] t12;

    wire [(4/2)-1:0] Xh_P_Xl;
    wire [(4/2)-1:0] Yh_P_Yl;
    
    wire [(4/2)-1:0] Xh_P_Xl_tmp;
    wire [(4/2)-1:0] Yh_P_Yl_tmp;
    
    wire [(4/2)-1:0] comp_Xh_P_Xl;
    wire [(4/2)-1:0] comp_Yh_P_Yl;    
    
    
    wire [4-1:0] comp_t11;
    wire [4-1:0] t11_tmp;

    wire cin1;
    wire cin2;
    
    wire ov1;
    wire ob2;
    
    wire cout_sub1;
    wire cout_sub2;
    
    assign X_h = X[4-1:(4/2)];
    assign X_l = X[(4/2)-1:0];
    
    assign Y_h = Y[4-1:(4/2)];
    assign Y_l = Y[(4/2)-1:0];
    
    recursive_karatsuba_2 mult1 (.X(X_h), .Y(Y_h), .Z(t2));
    recursive_karatsuba_2 mult2 (.X(X_l), .Y(Y_l), .Z(t0));
    
    
    //Calculate z_m = x_h*y_l + x_l*y_h using Karatsuba's trick (the subtraction trick is used to use the N/2 bit multipliers only)
    
    assign cin1 = 0;
    assign cin2 = 0;
    subtract_Nbit #(.N(4/2)) sub1 (.a(X_l), .b(X_h), .cin(cin1), .S(Xh_P_Xl_tmp), .ov(ov1), .cout_sub(cout_sub1));  // N/2-bit subtractor with (N/2)-bit result
    subtract_Nbit #(.N(4/2)) sub2 (.a(Y_h), .b(Y_l), .cin(cin2), .S(Yh_P_Yl_tmp), .ov(ov2), .cout_sub(cout_sub2));  // N/2-bit subtractor with (N/2)-bit result
    
    // Take the absolute values for multiplication
    Complement2_Nbit #(.N(4/2)) comp1 (.a(Xh_P_Xl_tmp), .c(comp_Xh_P_Xl), .cout_comp());
    Complement2_Nbit #(.N(4/2)) comp2 (.a(Yh_P_Yl_tmp), .c(comp_Yh_P_Yl), .cout_comp());
    assign Xh_P_Xl = cout_sub1 ? Xh_P_Xl_tmp: comp_Xh_P_Xl;
    assign Yh_P_Yl = cout_sub2 ? Yh_P_Yl_tmp: comp_Yh_P_Yl;


    recursive_karatsuba_2 mult3 (.X(Xh_P_Xl), .Y(Yh_P_Yl), .Z(t11_tmp));

    assign t12 = t0 + t2;    // N-bit addition with N+1 bit output
    
    // Now determine the sign of the multiplied value. Depending on this sign we perfrom addition or subtraction (with carry)
    wire select;
    assign select = cout_sub1 ^ cout_sub2;
    assign t1 = select? (t12 - t11_tmp) : (t12 + t11_tmp);
    
    assign Z = (t2 << 4) + (t1 << (4/2)) + t0;
    

endmodule


module recursive_karatsuba_2(X, Y, Z);
    input [2-1:0] X;
    input [2-1:0] Y;
    output [(2*2 -1):0] Z;
    
    wire [(2/2)-1:0] X_h;
    wire [(2/2)-1:0] X_l;
    
    wire [(2/2)-1:0] Y_h;
    wire [(2/2)-1:0] Y_l;    
    
    wire [2-1:0] t0;
    wire [2-1:0] t2;
    
    
    wire [2:0] t1;
    wire [2-1:0] t11;
    wire [2:0] t12;

    wire [(2/2)-1:0] Xh_P_Xl;
    wire [(2/2)-1:0] Yh_P_Yl;
    
    wire [(2/2)-1:0] Xh_P_Xl_tmp;
    wire [(2/2)-1:0] Yh_P_Yl_tmp;
    
    wire [(2/2)-1:0] comp_Xh_P_Xl;
    wire [(2/2)-1:0] comp_Yh_P_Yl;    
    
    
    wire [2-1:0] comp_t11;
    wire [2-1:0] t11_tmp;

    wire cin1;
    wire cin2;
    
    wire ov1;
    wire ob2;
    
    wire cout_sub1;
    wire cout_sub2;
    
    assign X_h = X[2-1:(2/2)];
    assign X_l = X[(2/2)-1:0];
    
    assign Y_h = Y[2-1:(2/2)];
    assign Y_l = Y[(2/2)-1:0];
    
    assign t2 = X_h & Y_h;
    assign t0 = X_l & Y_l;
    
    
    //Calculate z_m = x_h*y_l + x_l*y_h using Karatsuba's trick (the subtraction trick is used to use the N/2 bit multipliers only)
    
    assign cin1 = 0;
    assign cin2 = 0;
    subtract_Nbit #(.N(2/2)) sub1 (.a(X_l), .b(X_h), .cin(cin1), .S(Xh_P_Xl_tmp), .ov(ov1), .cout_sub(cout_sub1));  // N/2-bit subtractor with (N/2)-bit result
    subtract_Nbit #(.N(2/2)) sub2 (.a(Y_h), .b(Y_l), .cin(cin2), .S(Yh_P_Yl_tmp), .ov(ov2), .cout_sub(cout_sub2));  // N/2-bit subtractor with (N/2)-bit result
    
    // Take the absolute values for multiplication
    Complement2_Nbit #(.N(2/2)) comp1 (.a(Xh_P_Xl_tmp), .c(comp_Xh_P_Xl), .cout_comp());
    Complement2_Nbit #(.N(2/2)) comp2 (.a(Yh_P_Yl_tmp), .c(comp_Yh_P_Yl), .cout_comp());
    assign Xh_P_Xl = cout_sub1 ? Xh_P_Xl_tmp: comp_Xh_P_Xl;
    assign Yh_P_Yl = cout_sub2 ? Yh_P_Yl_tmp: comp_Yh_P_Yl;
    
    assign t11_tmp = Xh_P_Xl & Yh_P_Yl;

    assign t12 = t0 + t2;    // N-bit addition with N+1 bit output
    
    // Now determine the sign of the multiplied value. Depending on this sign we perfrom addition or subtraction (with carry)
    wire select;
    assign select = cout_sub1 ^ cout_sub2;
    assign t1 = select? (t12 - t11_tmp) : (t12 + t11_tmp);
    
    assign Z = (t2 << 2) + (t1 << (2/2)) + t0;
    

endmodule



/*------------- Iterative Karatsuba: 32-bit Karatsuba using a single 16-bit Module*/


module mult_17(X, Y, Z);
input [16:0] X;
input [16:0] Y;
output [33:0] Z;

assign Z = X*Y;

endmodule


/*32-bit Karatsuba multipliction using a single 16-bit module*/

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
    
    assign C = g2;
    reg_with_enable #(.N(--)) Z(.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2) );  // Fill in the proper size of the register
    reg_with_enable #(.N(--)) T(.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2) );  // Fill in the proper size of the register
    
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
    output [32:0] W2;  // signals hoing to the registers as input
    

    input [1:0] sel_x;  // control signal 
    input [1:0] sel_y;  // control signal 
    
    input en_z;         // control signal 
    input [1:0] sel_z;  // control signal 
    input en_T;         // control signal 
    input [1:0] sel_T;  // control signal 
    
    input done;         // Final done signal
    
    
   
    
    //-------------------------------------------------------------------------------------------------
    
    // Write your datapath here
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
    
    reg [5:0] state, nxt_state;
    parameter S0 = 6'b000001;   // initial state
   // <define the rest of the states here>

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
            S0: 
                begin
					// Write your output and next state equations here
                end
			// Define the rest of the states
            default: 
                begin
				// Don't forget the default
                end            
        endcase
        
    end

endmodule


module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O );
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



