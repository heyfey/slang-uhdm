// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  virtual ifc mv;
  initial begin begin mv = u; end end
endmodule
