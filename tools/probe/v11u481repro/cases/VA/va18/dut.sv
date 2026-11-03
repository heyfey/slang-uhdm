// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; int arr[3];
  initial foreach (arr[i]) begin vt_t g; g = null; end
endmodule
