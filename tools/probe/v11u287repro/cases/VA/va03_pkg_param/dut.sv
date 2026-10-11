// § ifArrPortSizeIntTsUnlocated287
package p; parameter int R = 4; endpackage
interface ifc4 #(parameter int W = 8) (); logic [W-1:0] a; modport host (output a); endinterface
module leaf (input logic clk, ifc4.host arr[p::R]);
endmodule
module top; logic clk; ifc4 arr[4](); leaf u (clk, arr); endmodule
