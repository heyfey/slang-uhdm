// r10uvm80 arm c3 — CHARACTERISATION ONLY (r10uvm79's V-R1, the NESTED joint).
// § hpMidSelIdxAtPath79 scopes a mid-path select index "and everything nested
// under it" through joinRef(prefix, <the hier_path's name>).  The FIRST level is
// right; the level BELOW it still hard-joins with `.`.  One cell per shape of
// "something nested under the index", so the fourth spelling of the joint
// family is measured rather than argued.
class leaf80; int f; endclass
class deep80;
  leaf80 iarr[4];
  int    midx[4];
  int    pk4[4];
  int    i, j;
  function int fn80(int a); return a; endfunction
  function int probe80();
    int r;
    r = iarr[midx[i]].f;              // d1 depth 1 (the LANDED shape, control)
    r = iarr[midx[midx[i]]].f;        // d2 depth 2 — V-R1 proper
    r = iarr[midx[midx[midx[i]]]].f;  // d3 depth 3
    r = iarr[midx[i + j]].f;          // d4 OPERATION under the index
    r = iarr[midx[fn80(i)]].f;        // d5 CALL under the index
    r = iarr[pk4[i] > 0 ? midx[i] : midx[j]].f; // d6 ternary under the index
    iarr[midx[midx[i]]].f = 1;        // d7 LVALUE at depth 2
    return r;
  endfunction
endclass

module mdeep80;
  typedef struct { int f; } st80;
  st80 sarr[4];
  int  mi[4];
  int  z;
  initial begin
    z = sarr[mi[mi[z]]].f;            // d8 MODULE scope twin of d2
  end
endmodule
