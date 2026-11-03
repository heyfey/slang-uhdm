// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
program prg; import t::*; vt_t h; endprogram
module top; endmodule
