// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
typedef virtual ifc vt_t;
module top;
  initial begin vt_t g; g = null; end
endmodule
