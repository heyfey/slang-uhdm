// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic x;
  task tk(input vt_t v); endtask
  initial begin vt_t g; if (x) tk(g); end
endmodule
