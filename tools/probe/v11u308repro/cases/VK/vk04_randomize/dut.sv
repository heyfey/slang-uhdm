// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid;
  item iarr[4]; int midx[4]; int i; int j; int r; bit c; holder h; holder hd; item got; logic [7:0] v8;
  function int fn(int x); return x; endfunction
  function void probe();
    void'(iarr[i + 1].randomize());
  endfunction
endclass
module top; endmodule
