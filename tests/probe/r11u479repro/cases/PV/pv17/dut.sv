// § vifTdLocalIsRefVar479 (control: a local written `virtual ifc g;` stays logic_var)
interface ifc (input logic clk); logic a; endinterface
module top;
  initial begin virtual ifc g; end
endmodule
