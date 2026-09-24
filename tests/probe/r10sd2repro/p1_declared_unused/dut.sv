// p1 — a package DECLARED and never used.  Does it reach design.allPackages /
// design.topPackages at all?
package p1a;
  parameter int P1 = 7;
  typedef int p1_t;
endpackage
module top;
  initial $display("p1");
endmodule
