// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module sub; logic clk; ifc u(clk); virtual ifc g; initial g = u; endmodule
module top; for (genvar i = 0; i < 2; i++) begin : gg sub s(); end endmodule
