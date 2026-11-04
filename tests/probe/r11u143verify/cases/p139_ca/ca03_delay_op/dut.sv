// § caLhsDefNetUnlessOpRhs139
// case ca03: a delayed operation right-hand side
module top(input logic a, input logic b, output logic y);
  assign #1 y = a | b;
endmodule
