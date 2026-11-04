// § ppBasedLitWsAfter166
module top(input [3:0] a, output [11:0] r);
  assign r = {4'h 5, a, 4'h 6};
endmodule
