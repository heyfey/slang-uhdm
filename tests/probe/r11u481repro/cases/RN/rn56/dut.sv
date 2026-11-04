// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic x;
  initial begin semaphore s; process p; s = new(1); p = process::self(); x = (s == null); end
endmodule
