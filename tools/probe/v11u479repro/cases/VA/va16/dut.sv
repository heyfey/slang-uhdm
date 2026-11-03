// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
  typedef virtual ifc vt2_t;
endpackage
module top; import t::*; vt_t h; vt2_t g; endmodule
