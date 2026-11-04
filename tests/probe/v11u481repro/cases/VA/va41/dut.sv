// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; int x;
  initial begin vt_t g; x = 0; while (x < 2) begin x++; if (g == null) x = x; end end
endmodule
