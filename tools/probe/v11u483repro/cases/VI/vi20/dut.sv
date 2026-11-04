// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g; int k;
  initial case (1) (g == u): k = 1; default: k = 0; endcase
endmodule
