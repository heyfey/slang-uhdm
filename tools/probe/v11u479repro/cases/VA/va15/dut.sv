// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; vt_t h; always @* begin : b vt_t q; q = h; end endmodule
