// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class base #(int P = 2); item iarr[4]; int i; endclass
class grid extends base #(3);
  int r;
  function void probe(); r = iarr[i + P].f; endfunction
endclass
module top; endmodule
