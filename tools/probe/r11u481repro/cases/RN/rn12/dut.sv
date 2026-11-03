// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
`default_nettype none
module top; import t::*;
  initial begin vt_t g; g = null; end
endmodule
