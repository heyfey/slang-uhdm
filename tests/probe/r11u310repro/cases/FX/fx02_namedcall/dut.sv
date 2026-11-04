// § methIdxCallNameSpan310
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  function int fn(int x); return x; endfunction
  function void probe();
    r = iarr[fn(.x(h.k))].get();
    r = iarr[fwd(.y(h.k))].get();
    r = iarr[fwd(h.k)].get();
  endfunction
  function int fwd(int y); return y; endfunction
endclass
module top; endmodule
