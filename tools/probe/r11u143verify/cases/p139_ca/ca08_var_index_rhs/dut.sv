// § caLhsDefNetUnlessOpRhs139
// case ca08: a variable-indexed element right-hand side
module top(input logic [1:0] i, input logic [3:0] a, output logic y);
  assign y = a[i];
endmodule
