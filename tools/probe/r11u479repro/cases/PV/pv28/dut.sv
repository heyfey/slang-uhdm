// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  vt_t pv;
endpackage
module top; import t::*; endmodule
