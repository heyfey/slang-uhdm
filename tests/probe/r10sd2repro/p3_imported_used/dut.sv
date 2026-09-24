// p3 — imported AND a name actually used (the elaborated view has content).
package p3a;
  parameter int P3 = 7;
  typedef int p3_t;
  function automatic int f3(); return P3; endfunction
endpackage
module top;
  import p3a::*;
  int x = f3();
  p3_t y;
  initial $display("%0d %0d", x, y);
endmodule
