// § nonTrailIdxPathNestShape306
class item; int f; endclass
class holder; int k; endclass
class grid;
  item iarr[4]; int r; holder h;
  extern function void probe();
endclass
function void grid::probe();
  r = iarr[h.k].f;
endfunction
module top; endmodule
