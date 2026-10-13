// § methTailIdxNestShape310
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; endclass
class grid #(int N = 4);
  item iarr[N]; holder h; int r;
  function void probe();
    r = iarr[h.k].get();
  endfunction
endclass
module top; grid #(2) g; endmodule
