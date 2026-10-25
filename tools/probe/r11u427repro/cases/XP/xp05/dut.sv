// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b10x1;
  parameter X1 = 1'bx;
endpackage
module top(input logic [3:0] a, output logic [3:0] o, output logic q);
  import p::*;
  assign o = B;
  assign q = X1;
endmodule
