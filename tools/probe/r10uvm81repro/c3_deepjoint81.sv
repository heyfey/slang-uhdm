// r10uvm81 arm c3 — § selIdxNestPrefixJoinsByScope80 (law 2), carried forward
// from r10uvm80repro/c3_deepjoint.sv with the three cells this pass's brief
// asks for: DEPTH 4, an LVALUE below depth 2, and a nested select used as a
// CALL ARGUMENT.  Cells d1..d8 are r10uvm80's verbatim so the two passes'
// numbers stay comparable; d9..d13 are new.
//
// The law: the prefix a SELECT's index subtree hands to what is NESTED under it
// is `joinRef(prefix, <the select's base name>)`, never a hard `"."`.  d8 is the
// load-bearing control: `joinRef` returns `.` for a `.`-first prefix, so the
// MODULE world must not move at all.
class leaf81; int f; endclass
class deep81;
  leaf81 iarr[4];
  int    midx[4];
  int    pk4[4];
  int    i, j;
  function int fn81(int a); return a; endfunction
  function int probe81();
    int r;
    r = iarr[midx[i]].f;              // d1 depth 1 (the LANDED shape, control)
    r = iarr[midx[midx[i]]].f;        // d2 depth 2 — r10uvm79's V-R1 proper
    r = iarr[midx[midx[midx[i]]]].f;  // d3 depth 3
    r = iarr[midx[i + j]].f;          // d4 OPERATION under the index
    r = iarr[midx[fn81(i)]].f;        // d5 CALL under the index
    r = iarr[pk4[i] > 0 ? midx[i] : midx[j]].f; // d6 ternary under the index
    iarr[midx[midx[i]]].f = 1;        // d7 LVALUE at depth 2
    // --- r10uvm81's additions ---
    r = iarr[midx[midx[midx[midx[i]]]]].f;      // d9  DEPTH 4
    iarr[midx[midx[midx[i]]]].f = 2;            // d10 LVALUE at depth 3
    r = fn81(iarr[midx[midx[i]]].f);            // d11 nested select as a CALL ARGUMENT
    r = fn81(midx[midx[midx[i]]]);              // d12 depth-3 index as a CALL ARGUMENT
    r = iarr[midx[fn81(midx[i])]].f;            // d13 CALL ARGUMENT *under* the index
    return r;
  endfunction
endclass

module mdeep81;
  typedef struct { int f; } st81;
  st81 sarr[4];
  int  mi[4];
  int  z;
  function int mfn81(int a); return a; endfunction
  initial begin
    z = sarr[mi[mi[z]]].f;            // d8  MODULE scope twin of d2
    z = sarr[mi[mi[mi[mi[z]]]]].f;    // d14 MODULE twin of d9 (depth 4)
    sarr[mi[mi[mi[z]]]].f = 3;        // d15 MODULE twin of d10 (lvalue)
    z = mfn81(sarr[mi[mi[z]]].f);     // d16 MODULE twin of d11 (call argument)
  end
endmodule
