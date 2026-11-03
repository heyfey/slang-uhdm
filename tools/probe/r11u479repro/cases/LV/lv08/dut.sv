// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub; import t::*;
  initial begin vt_t g; end
endmodule
module top; sub u(); endmodule
