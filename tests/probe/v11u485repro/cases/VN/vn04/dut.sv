// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc #(parameter W = 1) (input logic clk); logic [W-1:0] a; endinterface
module top; logic clk; ifc #(4) u(clk);
  virtual ifc #(4) mv;
  initial mv = u;
endmodule
`default_nettype wire
