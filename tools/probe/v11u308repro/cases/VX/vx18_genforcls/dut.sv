// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
module top;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    class grid; item iarr[4]; int i; int r;
      function void probe(); r = iarr[i + gi].f; endfunction
    endclass
  end
endmodule
