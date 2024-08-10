module A(input x, input y, input z, input w, output reg oa);
always @* 
    begin
    oa = (x || !y || w) && (x || y || z || !w);
    end
endmodule

module B(input x, input y, input z, input w, output reg ob);
always @* 
    begin
    ob = (x || !y || z || !w) && (x || !y || !z || w);
    end
endmodule

module C(input x, input y, input z, input w, output reg oc);
always @* 
    begin
    oc = (x || y || !z || w);
    end
endmodule

module D(input x, input y, input z, input w, output reg od);
always @* 
    begin
    od = (x || !y || z || w) && (x || !y || !z || !w) && (y || z || !w);
    end
endmodule

module E(input x, input y, input z, input w, output reg oe);
always @* 
    begin
    oe = (!x && z && !w) || (!y && !z && !w);
    end
endmodule

module F(input x, input y, input z, input w, output reg of);
always @* 
    begin
    of = (x || y || !z) && (x || y || !w) && (x || !z || !w);
    end
endmodule

module G(input x, input y, input z, input w, output reg og);
always @* 
    begin
    og = (x || y || z) && (x || !y || !z || !w);
    end
endmodule
