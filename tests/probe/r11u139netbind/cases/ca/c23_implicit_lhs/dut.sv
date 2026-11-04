// § caLhsDefNetUnlessOpRhs139
module top(input p, input q, output a);
  assign imp = p & q;
  assign a = imp;
endmodule
