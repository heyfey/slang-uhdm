// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module m1; import t::*; vt_t h; endmodule
module m2; import t::*; int k; endmodule
module top; m1 a(); m2 b(); endmodule
