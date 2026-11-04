// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc#(8).mp vt_t;
  typedef virtual ifc #(8) vu_t;
endpackage
module top; import t::*; vt_t h; vu_t k;
endmodule
