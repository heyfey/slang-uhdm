// r10uvm89 ARM a2 — WHICH SELECT DECIDES: does the TRAILING bracket group's fate
// depend on whether the BASE of the path carries a select, crossed with
// LVALUE / RVALUE?  Every index below is a FUNC_CALL or a MEMBER SELECT, i.e. a
// kind `decompileHelper` has NO row for, so the only question the arm asks is
// EMPTY-BRACKETS vs GROUP-GONE.  Tags: P = base NOT selected, Q = base selected.
package q89;
  class leaf89; int f; int g[4]; endclass
  class mid89;  leaf89 arr[4]; int mi[8]; leaf89 amap[string]; endclass

  class top89;
    mid89   m[4];
    mid89   mm;
    leaf89  oo;
    int     idx[8];
    int     i;
    int     r;
    function string gn(); return "k"; endfunction

    function int probe89();
      // ---- P: the BASE carries NO select ----
      // P1 trail, LVALUE, call index
      mm.mi[gn().len()] = 1;
      // P2 trail, LVALUE, member-select index
      mm.mi[oo.f] = 2;
      // P3 trail, RVALUE, call index
      r = mm.mi[gn().len()];
      // P4 THREE components, mid select known + trail select unknown, LVALUE
      mm.arr[i].g[oo.f] = 3;
      // P5 THREE components, mid select unknown + trail select unknown, LVALUE
      mm.amap[gn()].g[oo.f] = 4;
      // P6 THREE components, mid unknown + trail unknown, RVALUE
      r = mm.amap[gn()].g[oo.f];

      // ---- Q: the BASE carries a select ----
      // Q1 trail, LVALUE, call index, base select KNOWN
      m[i].mi[gn().len()] = 5;
      // Q2 trail, LVALUE, member-select index, base select KNOWN
      m[i].mi[oo.f] = 6;
      // Q3 trail, RVALUE, call index, base select KNOWN
      r = m[i].mi[gn().len()];
      // Q4 trail, LVALUE, call index, base select UNKNOWN
      m[oo.f].mi[gn().len()] = 7;
      // Q5 trail, LVALUE, nested-select index, base select UNKNOWN
      m[idx[idx[i]]].mi[idx[idx[i]]] = 8;
      // Q6 THREE components, base select known, mid known, trail unknown, LVALUE
      m[i].arr[i].g[oo.f] = 9;
      return r;
    endfunction
  endclass
endpackage

module mq89;
  import q89::*;
  typedef struct { int f; int g[4]; } sl89;
  typedef struct { sl89 arr[4]; int mi[8]; } sm89;
  sm89 m[4];
  sm89 mm;
  sl89 oo;
  int  idx[8];
  int  k;
  int  r;
  function automatic int fk89(int a); return a; endfunction
  initial begin
    // N1 module, trail, LVALUE, call index, base NOT selected
    mm.mi[fk89(k)] = 1;
    // N2 module, trail, LVALUE, member index, base NOT selected
    mm.mi[oo.f] = 2;
    // N3 module, trail, RVALUE, call index, base NOT selected
    r = mm.mi[fk89(k)];
    // N4 module, trail, LVALUE, call index, base selected
    m[k].mi[fk89(k)] = 3;
    // N5 module, trail, RVALUE, call index, base selected
    r = m[k].mi[fk89(k)];
  end
endmodule
