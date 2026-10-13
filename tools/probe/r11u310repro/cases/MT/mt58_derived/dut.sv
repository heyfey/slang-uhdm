// § methTailIdxNestShape310
class item; int f; int k; virtual function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; endclass
class base; item iarr[4]; holder h; int r; endclass
class grid extends base;
  function void probe();
    r = iarr[h.k].get();
    r = super.iarr[h.k].get();
  endfunction
endclass
module top; endmodule
