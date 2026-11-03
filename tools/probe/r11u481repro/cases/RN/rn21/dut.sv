// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
module top;
  typedef virtual ifc vt_t;
  initial begin vt_t g; g = null; end
endmodule
