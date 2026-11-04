// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  virtual ifc mv;
  task t; mv = u; endtask
  initial t;
endmodule
`default_nettype wire
