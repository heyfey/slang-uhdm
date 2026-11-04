// § implicitNetDefaultType485
`default_nettype tri
interface ifc (input logic clk); logic a; endinterface
`default_nettype wire
module top; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
