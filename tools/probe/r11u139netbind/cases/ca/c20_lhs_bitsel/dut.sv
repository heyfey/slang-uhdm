// § caLhsDefNetUnlessOpRhs139
module top(input p, input q, output [1:0] a);
  assign a[0] = p & q;
  assign a[1] = 1'b0;
endmodule
