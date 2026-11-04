// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; modport mp (input a); endinterface
module top; logic clk; ifc u(clk); virtual ifc.mp g;
  initial g = u;
endmodule
