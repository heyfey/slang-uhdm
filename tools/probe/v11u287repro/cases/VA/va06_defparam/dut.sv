// § ifArrPortSizeIntTsUnlocated287
interface ifc4 #(parameter int W = 8) (); logic [W-1:0] a; modport host (output a); endinterface
module leaf #(parameter int R = 3) (input logic clk, ifc4.host arr[R]);
endmodule
module top; logic clk; ifc4 arr[4](); leaf u (clk, arr); defparam u.R = 4; endmodule
