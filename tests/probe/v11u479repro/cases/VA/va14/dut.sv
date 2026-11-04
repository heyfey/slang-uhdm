// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
typedef virtual ifc vu_t;
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; vt_t h; vu_t g; endmodule
