// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub; import t::*;
  initial begin vt_t g; g = null; end
  assign zz = 1'b1;
endmodule
module top; sub a(); sub b();
endmodule
