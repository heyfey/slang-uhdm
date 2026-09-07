// v201 arm G — EXPRESSION-defaulted copies of every shape, and a system
// function fold.
package p201vg;
  parameter G_A = 13;
  parameter G_B = G_A + 1;
  parameter G_C = G_A * 2 - 3;
  parameter G_D = $clog2(16);
  parameter G_E = G_D;
  parameter G_F = {G_A[3:0], 4'h2};
  parameter G_G = G_A > 3 ? 5 : 6;
endpackage
import p201vg::*;
module m201vg;
endmodule
