// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  virtual ifc mv;
  initial begin mv = u; if (mv == u) mv = null; end
endmodule
`default_nettype wire
