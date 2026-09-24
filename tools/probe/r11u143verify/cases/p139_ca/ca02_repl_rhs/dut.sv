// § caLhsDefNetUnlessOpRhs139
// case ca02: a replication of a port as the right-hand side
module top(input logic a, output logic [1:0] y);
  assign y = {2{a}};
endmodule
