// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  always @* begin vt_t g; g = null; end
endmodule
module top2; import t::*;
  initial begin vt_t g; g = null; end
endmodule
