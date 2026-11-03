// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; int x;
  initial begin vt_t g; case (g == null) 1'b1: x = 1; default: x = 0; endcase end
endmodule
