// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
package u;
  import t::*;
  typedef virtual ifc.mp vm_t;
  vt_t a; vm_t b;
endpackage
module top; import u::*; import t::*; vt_t h; vm_t g; endmodule
