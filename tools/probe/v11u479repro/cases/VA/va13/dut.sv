// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub(input logic c); import t::*; vt_t h; endmodule
module top; logic c; sub u(c); endmodule
