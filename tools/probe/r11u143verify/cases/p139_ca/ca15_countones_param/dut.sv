// § caLhsDefNetUnlessOpRhs139
// case ca15: a $countones call over a parameter
module top #(parameter logic [3:0] P = 4'b1011) (output int a);
  assign a = $countones(P);
endmodule
