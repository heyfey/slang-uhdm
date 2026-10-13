// § nonTrailIdxPathNestShape306
class item; int f; int g[4]; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; static int sk; endclass
class grid;
  item iarr[4]; int midx[4]; int i; int j; int r; bit c; logic [3:0] v; holder h; holder hd; item got;
  item amap[int]; item qq[$]; item dyn[];
  function int fn(int x); return x; endfunction
  function void probe();
    r = iarr[h.k].f + iarr[hd.k].f;
  endfunction
endclass
module top; endmodule
