// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u[2](clk);
  virtual ifc mv;
  initial mv = u[1];
endmodule
`default_nettype wire
