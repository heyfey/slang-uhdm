// § caLhsDefNetUnlessOpRhs139
module top(input s, input p, input q, output a);
  assign a = s ? p : q;
endmodule
