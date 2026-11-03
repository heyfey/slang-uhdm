// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; initial begin vt_t g; begin vt_t k; end end endmodule
