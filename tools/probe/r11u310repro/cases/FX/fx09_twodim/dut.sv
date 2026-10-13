// § methTailIdxNestShape310
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; int idx[4]; endclass
class grid;
  item i2[4][4]; holder h; int r; int i;
  function void probe();
    r = i2[h.k][i].get();
    r = i2[i][h.k].get();
  endfunction
endclass
module top; endmodule
