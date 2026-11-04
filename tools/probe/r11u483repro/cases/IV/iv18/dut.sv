// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  virtual ifc mv;
  wire w1;
  initial mv = u;
  assign w2 = 1'b0;
endmodule
