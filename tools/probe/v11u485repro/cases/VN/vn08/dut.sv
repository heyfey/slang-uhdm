// § noneBindSameDefRead485v
`default_nettype none
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  module inner; virtual ifc mv; initial mv = u; endmodule
  inner i();
endmodule
`default_nettype wire
