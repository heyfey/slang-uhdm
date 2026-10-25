// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x0z;
endpackage
module sub(input [3:0] i);
endmodule
module top;
  sub u(.i(p::B));
endmodule
