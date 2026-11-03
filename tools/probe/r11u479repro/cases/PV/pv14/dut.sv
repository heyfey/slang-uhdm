// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  typedef int i_t;
endpackage
module top; import t::*; i_t k; endmodule
