// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter logic B0 = 1'B0;
  parameter logic BX = 1'Bx;
  parameter B1 = 1'B1;
endpackage
module top(input a, output o, output q, output r);
  import p::*;
  assign o = a & B0;
  assign q = a | BX;
  assign r = a ^ p::B1;
endmodule
