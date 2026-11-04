// § implicitNetDefaultType485
`default_nettype tri
module top; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
