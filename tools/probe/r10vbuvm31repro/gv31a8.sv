// v31a8 — clause-3 boundary literals: unsized-based, unbased-unsized, wide bare
// decimals, and real/shortreal/time elements.
module v31m8;
  class v31c8;
    int       ca[] = '{'d9, 'd8};
    int       cb[] = '{'1};
    int       cc[] = '{5000000000, 1};
    shortreal cd[] = '{1.0, 2.0};
    real      ce[] = '{1.0, 2.0};
    time      cf[] = '{1, 2};
    bit [3:0] cg[] = '{4'hf, 1};
    int       ch[] = '{-1, 2};
    int       ci[] = '{32'sd7, 1};
  endclass
  v31c8 h = new();
  initial $display(h.ca.size());
endmodule
package v31p8;
  int       pa[] = '{'d9, 'd8};
  int       pc[] = '{5000000000, 1};
  shortreal pd[] = '{1.0, 2.0};
  time      pf[] = '{1, 2};
  bit [3:0] pg[] = '{4'hf, 1};
  int       ph[] = '{-1, 2};
endpackage
