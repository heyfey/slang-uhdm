// § pkgVirtIfaceTd479
package t;
  typedef virtual ifc vt_t;
endpackage
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
module top; import t::*; vt_t h; logic clk; ifc u(clk); initial h = u; endmodule
