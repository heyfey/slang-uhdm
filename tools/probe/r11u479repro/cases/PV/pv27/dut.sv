// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub; import t::*; vt_t h; endmodule
module top; sub u1(); sub u2(); endmodule
