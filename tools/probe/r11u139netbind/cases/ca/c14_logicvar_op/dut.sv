// § caLhsDefNetUnlessOpRhs139
module top(input p, input q, output a);
  logic l;
  assign l = p & q;
  assign a = l;
endmodule
