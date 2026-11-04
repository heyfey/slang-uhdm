// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g; int k;
  task tk(virtual ifc x); g = x; endtask
  initial begin if (k == 0) tk(u); else g = null; end
endmodule
