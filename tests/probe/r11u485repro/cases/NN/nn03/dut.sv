// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module sub; logic clk; ifc u(clk);
  virtual ifc mv;
  initial mv = u;
endmodule
module top; sub s1(); sub s2(); endmodule
`default_nettype wire
