// § hpFnStaticTrailScopeJoin246
package p;
  class c;
    function int cnt();
      static int n;
      n++;
      return n;
    endfunction
    function int peek();
      int x;
      x = cnt.n + 1;
      if (cnt.n > 2) x = cnt.n;
      return x;
    endfunction
  endclass
  function int pf();
    static int k;
    k++;
    return k;
  endfunction
  function int pg();
    return pf.k;
  endfunction
endpackage
module top;
  initial $display(p::pg());
endmodule
