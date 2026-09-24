// § caLhsDefNetUnlessOpRhs139
// case ca13: a part-select of a package parameter as the right-hand side, top module
package pq2; parameter logic [7:0] C = 8'h3C; endpackage
module top(output logic [1:0] y);
  assign y = pq2::C[5:4];
endmodule
