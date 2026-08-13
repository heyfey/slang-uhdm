// p5 — TWO packages, one imported one not: does membership/ORDER of the design
// package vectors follow SOURCE order or USE?
package p5b;
  parameter int P5B = 2;
endpackage
package p5a;
  parameter int P5A = 1;
endpackage
module top;
  import p5a::*;
  int x = P5A;
  initial $display("%0d", x);
endmodule
