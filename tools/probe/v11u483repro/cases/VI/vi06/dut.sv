// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g; int k;
  initial begin k = (g == u); g <= u; end
endmodule
