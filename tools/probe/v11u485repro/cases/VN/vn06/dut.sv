// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk), w(clk);
  virtual ifc mv;
  initial begin mv = u; mv = w; mv = u; end
endmodule
`default_nettype wire
