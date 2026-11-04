// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  virtual ifc mv;
  function automatic void f(virtual ifc x); mv = x; endfunction
  initial f(u);
endmodule
`default_nettype wire
