// § methTailIdxNestShape310
class C #(int N = 1); localparam int K = N; endclass
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  function void probe();
    r = iarr[C#(2)::K + h.k].get();
    r = iarr[h.k + C#(1)::K].get();
  endfunction
endclass
module top; endmodule
