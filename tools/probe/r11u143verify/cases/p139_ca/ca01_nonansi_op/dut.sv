// § caLhsDefNetUnlessOpRhs139
// case ca01: an operation right-hand side onto a non-ANSI output port
module top(a, b, y);
  input a, b;
  output y;
  wire y;
  assign y = a & b;
endmodule
