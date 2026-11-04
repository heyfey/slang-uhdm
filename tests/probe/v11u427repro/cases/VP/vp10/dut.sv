// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 1'Bx;
endpackage
module top(output [7:0] o);
  assign o = p::B;
endmodule
