// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; if (1) begin : g initial begin vt_t q; end end endmodule
