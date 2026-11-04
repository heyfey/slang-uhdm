// § caLhsDefNetUnlessOpRhs139
// case ca16: a $clog2 of a parameter in a sub-module whose instance overrides it
module sub #(parameter int W = 8) (output int a);
  assign a = $clog2(W);
endmodule
module top(output int a); sub #(.W(32)) u(.a(a)); endmodule
