// § caLhsDefNetUnlessOpRhs139
module top(output logic [2:0] a);
  logic [2:0] o;
  assign o = 3'('1);
  assign a = o;
endmodule
