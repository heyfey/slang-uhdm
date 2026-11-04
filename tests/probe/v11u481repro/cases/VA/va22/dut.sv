// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; initial begin virtual ifc g; g = null; end endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; logic clk; ifc u(clk);
endmodule
