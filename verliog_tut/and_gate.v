module and_gate(a,b,o)
input a; 
input b;
output o;
always @(a or b)
    begin 
        o= a&b;
    end
endmodule
and_gate