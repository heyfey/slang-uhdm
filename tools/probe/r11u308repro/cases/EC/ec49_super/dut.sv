// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class base; item iarr[4]; endclass
class grid extends base; int i; int r;
  function void probe(); r = super.iarr[i+1].f; endfunction
endclass
module top; endmodule
