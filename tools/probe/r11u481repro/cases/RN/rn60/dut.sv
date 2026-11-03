// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  assign zz = 1'b0;
  initial begin vt_t g; g = null; end
endmodule
