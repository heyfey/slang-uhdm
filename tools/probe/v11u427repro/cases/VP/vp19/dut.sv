// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
module top(output [7:0] o);
  assign o = {p::B, p::B};
endmodule
