// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
interface jfc (input logic clk); logic b; endinterface
package t;
  typedef virtual jfc wt_t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; vt_t h; wt_t g; endmodule
