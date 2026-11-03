// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; logic [3:0] x;
  initial begin typedef logic [3:0] T; T y; y = 1; x = y; end
endmodule
