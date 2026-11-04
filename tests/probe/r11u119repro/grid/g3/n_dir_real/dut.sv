`define UNUSED_M 1
module top(input real b, output real y1, y2);
  assign y1 = 1.5     + b;
  assign y2 = 2.0e3     + b;
endmodule
