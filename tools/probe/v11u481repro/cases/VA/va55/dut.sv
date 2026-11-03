// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  
endpackage
package q; parameter int g = 5; endpackage
module top; import t::*; int x;
  initial begin vt_t g; g = null; end
  initial x = q::g;
endmodule
