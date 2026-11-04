// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g, h;
  initial begin : b g = u; end
  always @(clk) begin : c h = u; end
endmodule
