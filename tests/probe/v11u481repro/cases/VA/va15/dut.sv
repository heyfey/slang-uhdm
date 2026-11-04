// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub; import t::*;
  initial begin vt_t g; g = null; end
endmodule
module top; import t::*; sub s1();
  initial begin vt_t h; h = null; end
endmodule
