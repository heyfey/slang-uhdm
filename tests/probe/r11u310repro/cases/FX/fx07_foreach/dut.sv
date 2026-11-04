// § methTailIdxNestShape310
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  function void probe();
    foreach (iarr[q]) r = iarr[h.arr[q].k].get();
  endfunction
endclass
module top; endmodule
