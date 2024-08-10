module testbench;
reg x,y,z,w;
integer i,j,k,l;
wire oa,ob,oc,od,oe,of,og;
A a_instance(.oa(oa), .x(x),.y(y),.z(z), .w(w));
B b_instance(.ob(ob), .x(x),.y(y),.z(z), .w(w));
C c_instance(.oc(oc), .x(x),.y(y),.z(z), .w(w));
D d_instance(.od(od), .x(x),.y(y),.z(z), .w(w));
E e_instance(.oe(oe), .x(x),.y(y),.z(z), .w(w));
F f_instance(.of(of), .x(x),.y(y),.z(z), .w(w));
G g_instance(.og(og), .x(x),.y(y),.z(z), .w(w));
initial begin
$dumpvars();
$display("23b1060: Madhav R Babu");
$monitor("x: %b y:%b z:%b w:%b A:%b B:%b B:%b D:%b E:%b F:%b G:%b", x, y,z,w,oa,ob,oc,od,oe,of,og);
x=0; y=0; z=0; w=0; #1;
for(i=0; i<1; i=i+1) begin
    for(j=0; j<2; j=j+1) begin
        for(k=0; k<2; k=k+1) begin
            for(l=0; l<2; l=l+1) begin
                x=i; y=j; z=k; w=l;
                #1;
                end
            end
        end
    end
x=1; y=0; z=0; w=0; #1;
x=1; y=0; z=0; w=1; #1;
end
endmodule