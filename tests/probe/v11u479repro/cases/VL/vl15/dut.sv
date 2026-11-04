// § vifTdLocalIsRefVar479
interface ifc #(parameter int W = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
typedef virtual ifc #(4) vt_t;
module top; initial begin vt_t g; end endmodule
