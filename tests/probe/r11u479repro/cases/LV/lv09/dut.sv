// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
typedef virtual ifc vt_t;
module top;
  always @* begin vt_t g; g = null; end
endmodule
