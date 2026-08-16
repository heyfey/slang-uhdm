// v2 — the tf_call ARGUMENT arm: `int b2 = f2(a2);`
package p2;
  int a2 = 1;
  function automatic int f2(int x); return x + 1; endfunction
  int b2 = f2(a2);
endpackage
package q2;
  import p2::*;
  class c2;
    int own2;
  endclass
endpackage
module m2;
  q2::c2 h2;
endmodule
