// § ifaceValNoneBindsInst485
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk;
  module inner; ifc u(clk); virtual ifc g; initial g = u; endmodule
  inner i1();
endmodule
`default_nettype wire
