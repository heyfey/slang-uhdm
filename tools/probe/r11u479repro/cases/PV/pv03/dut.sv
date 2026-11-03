// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp (input a); endinterface
package t;
  typedef virtual ifc.mp vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
