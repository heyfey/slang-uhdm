// § implicitNetDefaultType485
`default_nettype tri
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
  assign w2 = clk;
endmodule
`default_nettype wire
