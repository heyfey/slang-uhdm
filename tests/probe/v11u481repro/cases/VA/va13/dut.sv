// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; int x;
  initial begin vt_t g; begin if (g == null) x = 1; end end
endmodule
