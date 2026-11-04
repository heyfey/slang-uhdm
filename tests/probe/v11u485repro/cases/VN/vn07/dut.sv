// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module sub #(parameter P = 1); logic clk; ifc u(clk);
  virtual ifc mv;
  initial mv = u;
endmodule
module top; sub #(1) s1(); sub #(2) s2(); endmodule
`default_nettype wire
