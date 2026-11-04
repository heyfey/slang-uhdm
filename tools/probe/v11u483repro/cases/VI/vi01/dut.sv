// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  task tk(virtual ifc x); g = x; endtask
  initial tk(u);
endmodule
