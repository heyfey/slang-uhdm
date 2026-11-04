// § implicitNetDefaultType485
interface ifc (input logic clk); logic a; endinterface
`default_nettype tri
module sub; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
`default_nettype wire
module top; logic clk; ifc u(clk); virtual ifc g; sub s();
  initial g = u;
endmodule
