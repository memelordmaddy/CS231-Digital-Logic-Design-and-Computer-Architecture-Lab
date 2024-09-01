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

    always @(*) begin
        if (en_z) begin
            if (sel_z == 2'b01) begin
                W1 = Z + {32'b0, mul_res};  // Z += z0
            end else if (sel_z == 2'b10) begin
                W1 = Z + {mul_res, 32'b0};  // Z += z2
            end else if (sel_z == 2'b11) begin
                W1 = Z + {15'b0, W2, 16'b0};  // Z += z1
            end else begin
                W1 = Z + {64'b0};  // Default case
            end
        end

        if (en_T) begin
            if (sel_T == 2'b11) begin
                W2 = T + {1'b0, mul_res};
            end else if (sel_T == 2'b10) begin
                if ((X[15:0] > X[31:16]) ^ (Y[15:0] < Y[31:16])) begin
                    W2 = T - {1'b0, mul_res};
                end else begin
                    W2 = T + {1'b0, mul_res};
                end
            end else begin
                W2 = T + 33'b0;  // Default case
            end
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
            state <= S0;
            nxt_state <= S0;
        end else if (enable) begin
            state <= nxt_state;
        end
    end
    
    always @(*) begin
        sel_x <= 2'b00;
        sel_y <= 2'b00;
        sel_z <= 2'b00;
        sel_T <= 2'b00;
        en_T <= 0;
        en_z <= 0;
        done <= 0;
        nxt_state <= S0;

        case(state)
            S0: begin
                nxt_state <= S1;
            end
            S1: begin
                sel_x <= 2'b10;
                sel_y <= 2'b10;
                sel_z <= 2'b10;
                sel_T <= 2'b11;
                en_T <= 1;
                en_z <= 1;
                nxt_state <= S2;
            end
            S2: begin
                sel_x <= 2'b01;
                sel_y <= 2'b01;
                sel_z <= 2'b01;
                sel_T <= 2'b11;
                en_T <= 1;
                en_z <= 1;
                nxt_state <= S3;
            end
            S3: begin
                sel_x <= 2'b11;
                sel_y <= 2'b11;
                sel_z <= 2'b00;
                sel_T <= 2'b10;
                en_T <= 1;
                en_z <= 1;
                nxt_state <= S4;
            end
            S4: begin
                sel_z <= 2'b11;
                en_z <= 1;
                nxt_state <= S5;
            end
            S5: begin
                done <= 1;
                nxt_state <= S5;
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

module mult_16(
    input [15:0] X,
    input [15:0] Y,
    output [31:0] Z
);
    assign Z = X * Y;
endmodule
