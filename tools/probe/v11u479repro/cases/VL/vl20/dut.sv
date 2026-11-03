// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
class K; typedef virtual ifc v_t; endclass
typedef K::v_t w_t;
module top; initial begin w_t g; end endmodule
