// v196 arm X1 — INSTANCE COUNT.  A file-scope import, a leaf module DEFINED in
// this file and instantiated ONE, TWO and THREE times.  Does the multiplicity
// depend on the number of elaborated instances?
import quarryPkg::*;
module xLeaf(input int a, output int b);
  parameter int X_OWN = 1;
  assign b = a + quarryTake(1);
endmodule
module xOne(input int a, output int b);
  xLeaf u0(a, b);
endmodule
module xThree(input int a, output int b);
  int w1, w2;
  xLeaf u0(a, w1);
  xLeaf u1(w1, w2);
  xLeaf u2(w2, b);
endmodule
