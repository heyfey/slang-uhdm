class item;
  int f;
endclass
class holder;
  item arr[4];
  int  idx[4];
endclass

class grid;
  item   iarr[4];
  item   iarr2[4][4];
  int    midx[4];
  int    j;
  logic [7:0] pk;
  holder h;
  function int fn(int x); return x; endfunction

  function int probe();
    int i;
    int r;
    r = iarr[midx[i]].f;            // d1 depth-2 nested select index
    r = iarr[midx[midx[i]]].f;      // d2 depth-3
    r = iarr[i + 1].f;              // d3 operation index
    r = iarr[midx[i] + 1].f;        // d4 operation CONTAINING a select
    r = iarr[2].f;                  // d5 constant index
    r = iarr[h.idx[i]].f;           // d6 member-access chain index
    r = iarr[fn(i)].f;              // d7 function-call index
    iarr[midx[i]].f = 3;            // d8 LVALUE
    r = iarr2[midx[i]][j].f;        // d9 multi-dim base select
    r = h.arr[midx[i]].f;           // d10 MEMBER select (not base) nested idx
    r = iarr[pk[3:0]].f;            // d11 part-select index
    return r;
  endfunction
endclass
