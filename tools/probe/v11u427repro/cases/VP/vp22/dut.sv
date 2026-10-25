// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
  parameter C = B;
endpackage
module top(output [3:0] o);
  assign o = p::C;
endmodule
