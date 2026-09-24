// § caLhsDefNetUnlessOpRhs139
// case ca17: a bit-select of a wildcard-imported package parameter
package pi; parameter logic [3:0] B = 4'b0110; endpackage
module top(output logic y);
  import pi::*;
  assign y = B[2];
endmodule
