// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc #(8, 4).mp vt_t;
endpackage
module top; import t::*; logic clk; ifc #(8,4) u(clk); vt_t h;
endmodule
