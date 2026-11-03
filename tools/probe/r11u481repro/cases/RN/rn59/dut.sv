// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  initial begin vt_t g; g = null; end
  assign zz = 1'b0;
endmodule
