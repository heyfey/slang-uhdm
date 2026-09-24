// § caLhsDefNetUnlessOpRhs139
// case ca05: a part-select right-hand side
module top(input logic [3:0] a, output logic [1:0] y);
  assign y = a[3:2];
endmodule
