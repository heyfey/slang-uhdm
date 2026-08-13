// p2 — a package WILDCARD-IMPORTED into the module but none of its names used.
package p2a;
  parameter int P2 = 7;
  typedef int p2_t;
endpackage
module top;
  import p2a::*;
  initial $display("p2");
endmodule
