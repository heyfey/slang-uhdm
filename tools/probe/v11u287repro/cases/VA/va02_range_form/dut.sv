// § ifArrPortSizeIntTsUnlocated287
interface ifc4 #(parameter int W = 8) (); logic [W-1:0] a; modport host (output a); endinterface
module leaf #(parameter int R = 4) (input logic clk, ifc4.host arr[0:R-1]);
endmodule
module top; logic clk; ifc4 arr[4](); leaf u (clk, arr); endmodule
