// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; item m[string]; string key; int r; int i; string ks[4];
  function void probe(); r = m[key].get(); r = m[ks[i]].f; if (m.exists(ks[i + 1])) r = 1; endfunction
endclass
module top; endmodule
