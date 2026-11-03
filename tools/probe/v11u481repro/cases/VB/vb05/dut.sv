// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
typedef virtual ifc #(8).mp vt_t;
module top; logic clk; vt_t h;
endmodule
