// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  class C; vt_t h; endclass
endpackage
module top; import t::*; C c; endmodule
