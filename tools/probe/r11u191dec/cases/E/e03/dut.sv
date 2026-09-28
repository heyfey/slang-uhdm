// (r11u191 N1082) where a folded package parameter initializer is located: an operation, a reference, a parenthesized
// reference, a nested ternary, a ternary whose chosen arm is an operation led by a literal
package p;
  parameter int W = 4;
  parameter int L = $clog2(W);
  parameter int A = L + 1;
  parameter int B = (L);
  parameter int C = W > 8 ? 1 : W > 2 ? L : 3;
  parameter int D = W == 4 ? 2 * L : 0;
  parameter int E = W == 4 ? (L) : 0;
endpackage
module top(output int o);
  import p::*;
  assign o = A + B + C + D + E;
endmodule
