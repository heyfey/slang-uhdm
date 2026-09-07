// v196 arm X2 — PARAMETER SPECIALIZATIONS.  Three distinct overrides of a
// parameterized module written in a file that carries a file-scope import.
import quarryPkg::*;
module xParam #(parameter int P = 1) (input int a, output int b);
  assign b = a + P + quarryTake(P);
endmodule
module xSpecTop(input int a, output int b);
  int w1, w2;
  xParam #(.P(1)) s1(a, w1);
  xParam #(.P(2)) s2(w1, w2);
  xParam #(.P(3)) s3(w2, b);
endmodule
