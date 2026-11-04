// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic x;
  initial begin : nb vt_t g; begin : inner g = null; end end
endmodule
