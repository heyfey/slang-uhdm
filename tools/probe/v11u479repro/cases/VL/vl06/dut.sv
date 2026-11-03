// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
module top; typedef virtual ifc.mp vm_t; initial begin vm_t g; vm_t k; end endmodule
