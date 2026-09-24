class item; int f; endclass
class holder; item arr[4]; int idx[4]; item aa[string]; endclass

class recv;
  item   iarr[4];
  item   iarr2[4][4];
  item   iq[$];
  item   idyn[];
  item   iai[int];
  item   ias[string];
  int    midx[4];
  string skeys[4];
  int    j;
  holder h;
  function int probe();
    int i; int r;
    r = iq[midx[i]].f;                // f1  queue receiver
    r = idyn[midx[i]].f;              // f2  dynamic receiver
    r = iai[midx[i]].f;               // f3  assoc[int] receiver
    r = ias[skeys[i]].f;              // f4  assoc[string], bit-select index
    r = iarr2[midx[i]][j].f;          // f5  multi-dim, sel index dim0
    r = iarr2[j][midx[i]].f;          // f6  multi-dim, sel index dim1
    r = iarr2[midx[i]][midx[j]].f;    // f7  multi-dim, both
    r = h.arr[midx[i]].f;             // f8  MEMBER select (site 2)
    r = h.aa[skeys[i]].f;             // f9  member assoc select
    iarr[midx[i]].f = 3;              // f10 LVALUE base select
    h.arr[midx[i]].f = 4;             // f11 LVALUE member select
    iq[midx[i]].f = 5;                // f12 LVALUE queue
    return r;
  endfunction
endclass
