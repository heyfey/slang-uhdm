// § ndtSameFileDirective485v
module top; logic clk; ifc u(clk); virtual ifc g;
  initial g = u;
endmodule
