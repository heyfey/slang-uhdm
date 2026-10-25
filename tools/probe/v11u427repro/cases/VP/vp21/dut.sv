// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
class K;
  int x = p::B;
endclass
module top(output [3:0] o);
  assign o = p::B;
endmodule
