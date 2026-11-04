// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic [1:0] q;
  initial begin vt_t g; q = 0; for (int i = 0; i < 2; i++) if (g == null) q[i] = 1; end
endmodule
