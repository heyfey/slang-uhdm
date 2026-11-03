// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
typedef virtual ifc vt_t;
module sub; initial begin vt_t g; end endmodule
module top; sub u1(); sub u2(); endmodule
