// q5 — a PACKAGE-scope queue variable (no class anywhere).  The other control:
// a package member must keep its stamp.
package p5;
  typedef struct { int a; } s5_t;
  s5_t q5[$];
endpackage
module top5;
  initial $display("%0d", p5::q5.size());
endmodule
