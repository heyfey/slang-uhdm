// § ifaceInstValueImplicitNet483
interface ifc #(parameter W = 4) (input logic clk); logic [W-1:0] a; endinterface
module top; logic clk; ifc #(8) u(clk); virtual ifc #(8) g;
  initial g = u;
endmodule
