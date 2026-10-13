// § nonTrailIdxNamesByChain308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
package pk; parameter int K = 1; endpackage
class grid; item iarr[4]; int i; int r;
  function void probe(); r = iarr[pk::K + i].f; r = iarr[pk::K].f; endfunction
endclass
module top; endmodule
