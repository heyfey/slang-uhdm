// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
module top;
  typedef virtual ifc vm_t;
  initial begin vm_t g; end
endmodule
