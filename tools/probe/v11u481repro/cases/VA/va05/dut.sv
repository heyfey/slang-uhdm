// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  for (genvar i = 0; i < 2; i++) begin : gb
    initial begin vt_t g; g = null; end
  end
endmodule
