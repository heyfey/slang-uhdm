// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; item i2[4][4]; int i; int j; int r;
  function void probe(); r = i2[i][j + 1].f; r = i2[i + 1][0].k; i2[j][i].f = r; endfunction
endclass
module top; endmodule
