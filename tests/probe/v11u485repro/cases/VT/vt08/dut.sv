// § implicitNetDefaultType485
interface ifc (input logic clk); logic a; endinterface
`default_nettype tri
module top; logic clk; ifc u(clk); virtual ifc g;
  module inner; endmodule
  initial g = u;
endmodule
`default_nettype wire
