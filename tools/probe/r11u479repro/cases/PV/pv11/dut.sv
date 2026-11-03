// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  typedef vt_t vt2_t;
endpackage
module top; import t::*; vt2_t h; endmodule
