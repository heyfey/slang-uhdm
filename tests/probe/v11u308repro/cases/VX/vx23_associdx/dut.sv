// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; item iarr[string]; string s; int r; item q[$]; int i;
  function void probe(); r = iarr[{s, "x"}].f; r = q[i + 1].f; r = q[$].f; endfunction
endclass
module top; endmodule
