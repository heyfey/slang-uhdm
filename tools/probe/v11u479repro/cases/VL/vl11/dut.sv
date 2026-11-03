// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
program prg; import t::*; initial begin vt_t g; end endprogram
module top; endmodule
