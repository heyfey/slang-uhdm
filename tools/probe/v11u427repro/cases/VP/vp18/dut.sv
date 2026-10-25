// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 8'HxF;
endpackage
module top(output [7:0] o);
  assign o = p::B;
endmodule
