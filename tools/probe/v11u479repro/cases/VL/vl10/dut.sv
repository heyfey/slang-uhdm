// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub; import t::*; always @* begin vt_t g; end endmodule
module top; sub u1(); sub u2(); endmodule
