// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class pc #(int W = 2); static int K = W; endclass
class grid; item iarr[8]; int i; int r;
  function void probe(); r = iarr[pc#(3)::K + i].f; endfunction
endclass
module top; endmodule
