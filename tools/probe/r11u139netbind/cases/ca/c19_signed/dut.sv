// § caLhsDefNetUnlessOpRhs139
module top(input [3:0] p, output [3:0] a);
  assign a = $signed(p);
endmodule
