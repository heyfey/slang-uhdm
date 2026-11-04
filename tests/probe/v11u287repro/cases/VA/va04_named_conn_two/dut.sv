// § ifArrPortSizeIntTsUnlocated287
interface ifc4 #(parameter int W = 8) (); logic [W-1:0] a; modport host (output a); endinterface
module leaf #(parameter int R = 4) (input logic clk, ifc4.host arr[R]);
endmodule
module top; logic clk; ifc4 a1[4](); ifc4 a2[4](); leaf u1 (.clk(clk), .arr(a1)); leaf u2 (.clk(clk), .arr(a2)); endmodule
