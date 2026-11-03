// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
module top; typedef virtual ifc vm_t; function automatic int f(); vm_t g; return 0; endfunction endmodule
