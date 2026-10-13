// § nonTrailIdxPathNestShape306
class item; int f; endclass
class holder; int k; endclass
class grid;
  item iarr[4]; int r; holder h;
  function int fn(int x); return x; endfunction
  function void probe(); r = iarr[fn(.x(h.k))].f; endfunction
endclass
module top; endmodule
