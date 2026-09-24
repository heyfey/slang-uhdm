// § caLhsDefNetUnlessOpRhs139
// case ca10: a part-select of a package parameter as the right-hand side, in a sub-module
package pq; parameter logic [7:0] C = 8'hA5; endpackage
module sub(output logic [1:0] y);
  assign y = pq::C[3:2];
endmodule
module top(output logic [1:0] y); sub u(.y(y)); endmodule
