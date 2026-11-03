// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual interface ifc vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
