// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
module top; typedef virtual ifc vm_t; initial begin : nb vm_t g; end endmodule
