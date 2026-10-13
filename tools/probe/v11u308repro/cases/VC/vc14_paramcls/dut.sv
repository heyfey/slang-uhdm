// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid #(int P = 1);
  item iarr[4]; int i; int r;
  function void probe(); r = iarr[P + i].f; endfunction
endclass
module top; grid #(2) g2 = new; endmodule
