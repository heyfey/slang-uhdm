// § pkgVifTdNameSpan481
interface ifc #(parameter int W = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc #(8) vt_t;
endpackage
module top; import t::*; vt_t h;
endmodule
