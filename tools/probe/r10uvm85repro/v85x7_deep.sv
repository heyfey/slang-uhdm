// v85x7 — THE ARGUMENT-DROP DIRECTION, which is the only direction this law
// REMOVES objects in (a missing object is a cmp head).  Depths 2..5 for both
// call families, with and without indices at every position, so the
// `segs11.size() <= 2` gate (SITE 2) and the TEXT `multiStep` gate (SITE 1) are
// each measured past the one depth the arms cover.
module v85x7;
  class l7;
    int arr[$];
    function void lm(int a); endfunction
    function void lm3(int a, int b, int c); endfunction
  endclass
  class m7;
    l7  l;
    l7  lv[2];
    int arr[$];
    function void mm(int a); endfunction
  endclass
  class n7;
    m7  m;
    m7  mv[2];
    function void nm(int a); endfunction
  endclass
  class c7v;
    n7  h;
    n7  hv[2];
    int q[$];
    int n;
    function void f(int k);
      // BUILT-IN at depth 2..5
      this.h.m.arr.delete(k);            // L26 depth 3
      this.h.m.l.arr.delete(k);          // L27 depth 4
      this.h.mv[1].l.arr.delete(k);      // L28 depth 4, index inside
      this.hv[k].m.l.arr.push_back(k);   // L29 depth 4, index at step 1
      this.h.m.l.arr.insert(0, k);       // L30 depth 4, TWO args
      // USER method at depth 2..4
      this.h.nm(k);                      // L32 depth 1 (args kept)
      this.h.m.mm(k);                    // L33 depth 2
      this.h.m.l.lm(k);                  // L34 depth 3
      this.h.mv[1].mm(k);                // L35 depth 2 with an index
      this.hv[1].m.mm(k);                // L36 depth 2, index at step 1
      this.hv[k].m.l.lm(k);              // L37 depth 3 with an index
      this.h.m.l.lm(k + 1);              // L38 depth 3, OPERATION actual
      this.h.m.l.lm3(k, k, k);           // L39 depth 3, THREE args
      this.h.mv[1].l.lm3(k, k, k);       // L40 depth 3, indexed 2nd step, 3 args
      this.q.delete(k);                  // L41 control
      this.n = 0;
    endfunction
  endclass
endmodule
