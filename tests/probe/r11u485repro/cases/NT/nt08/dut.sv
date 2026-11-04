// § implicitNetDefaultType485
`default_nettype tri
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  initial begin vt_t g; g = null; end
endmodule
`default_nettype wire
