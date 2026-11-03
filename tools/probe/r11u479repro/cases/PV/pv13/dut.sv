// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  class D #(type T = int); T x; endclass
endpackage
module top; import t::*; D #(vt_t) d; endmodule
