// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module sub; logic clk; ifc u(clk);
  virtual ifc mv;
  initial mv = u;
endmodule
module top; sub s1(); endmodule
module top2; sub s3(); endmodule
`default_nettype wire
