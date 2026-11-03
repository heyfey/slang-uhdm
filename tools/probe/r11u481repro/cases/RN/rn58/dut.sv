// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
interface top2; import t::*;
  task tk; begin vt_t g; g = null; end endtask
endinterface
module top; top2 u(); endmodule
