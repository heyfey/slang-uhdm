// § hpFnStaticTrailScopeJoin246
package p;
  function int cnt();
    static int n;
    n++;
    return n;
  endfunction
  function int peek();
    return cnt.n + 1;
  endfunction
endpackage
module top;
  import p::*;
  int r;
  initial r = peek();
endmodule
