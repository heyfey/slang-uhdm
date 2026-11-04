// § ndtSameFileDirective485v
`include "x.svh"
`default_nettype tri
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
`default_nettype wire
