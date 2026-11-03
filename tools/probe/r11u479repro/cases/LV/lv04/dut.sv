// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  initial fork vt_t g; join
endmodule
