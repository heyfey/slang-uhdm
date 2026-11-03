// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
typedef virtual ifc a_t;
typedef a_t b_t;
module top; initial begin b_t g; end endmodule
