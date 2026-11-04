// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g; int k;
  initial for (int i = 0; i < 2; i++) if (u == g) k = i;
endmodule
