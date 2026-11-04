// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; item iarr[4]; int i; int r;
  extern function int g(int x);
  function void probe(); r = iarr[g(i) + 1].f; endfunction
endclass
function int grid::g(int x); return x; endfunction
module top; endmodule
