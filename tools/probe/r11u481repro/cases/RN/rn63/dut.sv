// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  task tk3(input logic b); endtask
  initial begin vt_t g; tk3(g == null); end
endmodule
