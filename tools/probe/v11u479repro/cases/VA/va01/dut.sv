// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
interface J; import t::*; task tk(); vt_t g; endtask endinterface
module top; J j(); endmodule
