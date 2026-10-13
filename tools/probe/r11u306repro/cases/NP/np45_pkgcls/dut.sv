// § nonTrailIdxPathNestShape306
package pk;
  class item; int f; endclass
  class holder; int k; endclass
  class grid;
    item iarr[4]; int r; holder h;
    function void probe(); r = iarr[h.k].f; endfunction
  endclass
endpackage
module top; import pk::*; grid g; endmodule
