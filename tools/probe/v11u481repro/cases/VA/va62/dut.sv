// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub(output logic o); assign o = 1'b0; endmodule
module top; import t::*;
  initial begin vt_t g; g = null; end
  sub s(.o(w));
endmodule
