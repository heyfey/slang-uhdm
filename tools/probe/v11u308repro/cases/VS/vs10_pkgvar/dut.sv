// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
package pk; typedef struct { int f; } s_t; s_t sa[4]; endpackage
class grid; int i; int r;
  function void probe(); r = pk::sa[i + 1].f; pk::sa[i].f = r; endfunction
endclass
module top; endmodule
