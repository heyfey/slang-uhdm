// § caLhsDefNetUnlessOpRhs139
// case ca18: a bit-select of a package parameter assigned inside a generate block
package pg; parameter logic [3:0] A = 4'b0101; endpackage
module top(output logic y);
  if (1) begin : g
    assign y = pg::A[2];
  end
endmodule
