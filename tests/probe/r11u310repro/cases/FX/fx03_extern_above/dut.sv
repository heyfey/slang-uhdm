// § methIdxSelWholeByPath310
class item; int f; extern function int get(); endclass
function int item::get(); return f; endfunction
class holder; int k; int idx[4]; endclass
class grid;
  item iarr[4]; holder h; int r;
  extern function void probe();
endclass
function void grid::probe();
  r = iarr[h.k].get();
  r = iarr[h.idx[r]].get();
endfunction
module top; endmodule
