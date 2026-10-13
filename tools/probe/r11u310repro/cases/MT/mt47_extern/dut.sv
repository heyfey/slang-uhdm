// § methIdxSelWholeByPath310
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  extern function void probe();
endclass
function void grid::probe();
  r = iarr[h.k].get();
  r = iarr[h.idx[r]].get() + 1;
endfunction
module top; endmodule
