// g5 — the EXPLICIT-import path (`import p5::b5;`), which reaches the same arm
// through its `only23` name filter.  Measured, not assumed: pass 5's v4 is the
// record of why this cell exists.
package p5;
  int a5 = 1;
  int b5 = a5;
endpackage
package q5;
  import p5::b5;
  class c5;
    int own5;
  endclass
endpackage
module m5;
  q5::c5 h5;
endmodule
