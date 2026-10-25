// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b10x1;
endpackage
module top(output [7:0] o);
  import p::*;
  assign o = B;
endmodule
