// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; int x;
  initial begin vt_t g; g = null; end
  initial begin int g; g = 1; x = g; end
endmodule
