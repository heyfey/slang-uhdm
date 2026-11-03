// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc #(8).mp vt_t;
endpackage
package t2; import t::*; export t::*; typedef vt_t w_t;
endpackage
module top; import t2::*; logic clk; vt_t h;
endmodule
