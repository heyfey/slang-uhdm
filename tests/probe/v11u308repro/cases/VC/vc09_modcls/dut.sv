// § elabClsNonTrailIdxUnstored308
module top;
  class item; int f; endclass
  class grid; item iarr[4]; int i; int r;
    function void probe(); r = iarr[i - 1].f; endfunction
  endclass
endmodule
