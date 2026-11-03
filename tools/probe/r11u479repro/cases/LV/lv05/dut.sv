// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  typedef vt_t vt2_t;
endpackage
module top; import t::*;
  initial begin vt2_t g; end
endmodule
