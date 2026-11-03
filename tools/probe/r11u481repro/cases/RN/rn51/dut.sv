// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic c;
  always @(posedge c) begin vt_t g; g <= null; end
endmodule
