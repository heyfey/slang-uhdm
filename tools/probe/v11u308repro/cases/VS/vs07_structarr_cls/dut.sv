// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
typedef struct { int f; int k; } s_t;
class grid; s_t sarr[4]; int i; int r; holder h;
  function void probe(); r = sarr[i + 1].f; sarr[h.k].k = r; r = sarr[sarr[i].k].f; endfunction
endclass
module top; endmodule
