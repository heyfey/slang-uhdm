// § implicitNetDefaultType485
`default_nettype tri
`include "x.svh"
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
`default_nettype wire
