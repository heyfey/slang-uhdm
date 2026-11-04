// § bitSelMethodCallIdxSpan207 (built-in methods on a handle's members as the index; a part select and an operation around the call: the law's controls)
package p;
  class H;
    int q[$];
    string s;
    function int get(int i); return i; endfunction
  endclass
  class F;
    logic [15:0] v;
    int m [8];
    H h;
    function int g();
      int r;
      r = m[h.q.size()];
      r += m[h.s.len()];
      r += v[h.get(2) +: 4];
      r += m[h.get(1) + 1];
      r += m[(h.get(3))];
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
