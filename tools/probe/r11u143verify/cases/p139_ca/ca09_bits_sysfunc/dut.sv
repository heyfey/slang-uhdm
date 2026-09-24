// § caLhsDefNetUnlessOpRhs139
// case ca09: a $bits system call right-hand side onto an int output
module top(input logic [5:0] a, output int y);
  assign y = $bits(a);
endmodule
