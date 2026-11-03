// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  if (1) begin : gb
    initial begin vt_t g; g = null; end
  end
endmodule
