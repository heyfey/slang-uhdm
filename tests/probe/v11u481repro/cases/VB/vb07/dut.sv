// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc #(8).mp vt_t;
  class D; vt_t v; endclass
endpackage
module top; import t::*;
endmodule
