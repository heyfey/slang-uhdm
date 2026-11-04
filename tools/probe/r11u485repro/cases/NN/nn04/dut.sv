// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  virtual ifc mv;
  task tk(virtual ifc x); mv = x; endtask
  initial tk(u);
endmodule
`default_nettype wire
