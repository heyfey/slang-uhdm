// § implicitNetDefaultType485
`default_nettype tri
interface ifc (input logic clk); logic a; endinterface
module sub; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
`default_nettype wire
module top; sub s1(); sub s2(); endmodule
