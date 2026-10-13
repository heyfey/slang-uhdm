// § methTailIdxNestShape310
class item; int f; function int get(); return f; endfunction endclass
class holder; string s; int k; endclass
class grid;
  item sm[string]; holder h; int r;
  function void probe();
    r = sm[h.s].get();
    if (sm.exists(h.s)) r = sm[h.s].get();
  endfunction
endclass
module top; endmodule
