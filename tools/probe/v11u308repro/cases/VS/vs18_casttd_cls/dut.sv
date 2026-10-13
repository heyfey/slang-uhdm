// § castTsNonTrailIdxByChain308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; typedef int unsigned u_t; item iarr[4]; int i; int r;
  function void probe(); r = iarr[u_t'(i)].f; r = iarr[grid::u_t'(i + 1)].f; endfunction
endclass
module top; endmodule
