// § foldedBoundTsRefUnstored144
interface ifc;
   localparam int D = 3;
   logic [D:0] v;
endinterface
module top(input logic [3:0] a, output int o);
   ifc u();
   assign u.v = a;
   assign o = int'(u.v);
endmodule
