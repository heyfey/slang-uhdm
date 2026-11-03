// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
import t::*;
module m1; vt_t h; endmodule
module top; vt_t g; m1 u(); endmodule
