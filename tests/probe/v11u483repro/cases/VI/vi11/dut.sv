// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u1(clk); ifc u2(clk); virtual ifc g;
  wire w0; assign w9 = w0;
  initial begin g = u2; g = u1; end
endmodule
