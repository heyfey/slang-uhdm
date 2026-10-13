// § methTailIdxNestShape310
virtual class base_item; pure virtual function int get(); endclass
class item extends base_item; int f; virtual function int get(); return f; endfunction endclass
class holder; int k; int idx[4]; endclass
class grid;
  base_item iarr[4]; holder h; int r;
  function void probe();
    r = iarr[h.k].get();
    r = iarr[h.k + 1].get() + iarr[h.idx[2]].get();
  endfunction
endclass
module top; endmodule
