// § lvNestShapeMidIdxAtSel310
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; holder harr[4]; endclass
class grid;
  item iarr[4]; int midx[4]; int i; int j; int r; bit c; holder h; holder hd; item got; logic [7:0] v8; int ia[4];
  function int fn(int x); return x; endfunction
  function void probe();
    for (int q = 0; q < 2; q++) iarr[h.arr[q].f].f = q;
  endfunction
endclass
module top; endmodule
