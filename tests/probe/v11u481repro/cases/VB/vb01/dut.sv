// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc #(.W(8)).mp vt_t;
endpackage
module top; import t::*; logic clk; ifc #(8) u(clk); vt_t h;
endmodule
