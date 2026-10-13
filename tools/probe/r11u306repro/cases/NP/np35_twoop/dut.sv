// § nonTrailIdxPathNestShape306
class item; int f; int g[4]; endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; endclass
class grid;
  item iarr[4]; int midx[4]; int i; int j; int r; holder h; holder hd; item got;
  function int fn(int x); return x; endfunction
  function void probe();
    r = iarr[h.k + hd.k].f;
  endfunction
endclass
module top; endmodule
