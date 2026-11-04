// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
virtual class vb; pure virtual function int g(int x); endclass
class grid extends vb; item iarr[4]; int i; int r;
  function void probe(); r = iarr[g(i + 1)].f; endfunction
  virtual function int g(int x); return iarr[x - 1].k; endfunction
endclass
module top; endmodule
