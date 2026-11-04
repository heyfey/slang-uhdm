// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module sub; logic clk; ifc u(clk);
  virtual ifc mv;
  initial mv = u;
endmodule
module mid; sub s(); endmodule
module top; mid m1(); sub t(); endmodule
`default_nettype wire
