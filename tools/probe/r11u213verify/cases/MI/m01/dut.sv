// § bitSelMethodCallIdxSpan207 (method calls with two arguments, a nested call as the argument, a call on a this. path, a chained call, a two-dimensional select)
package p;
  class H;
    int q[$];
    function int get(int i, int j); return i + j; endfunction
    function int idx(); return 1; endfunction
    function H next(); return this; endfunction
  endclass
  class F;
    int m [8];
    int d2 [4][4];
    H h;
    function int g(int k);
      int r;
      r = m[h.get(k, 2)];
      r += m[h.get(h.idx(), k)];
      r += m[this.h.get(1, 1)];
      r += m[h.next().get(0, 3)];
      r += d2[h.idx()][h.get(0, 1)];
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
