// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
module top;
  initial begin virtual ifc g; g = null; end
endmodule
