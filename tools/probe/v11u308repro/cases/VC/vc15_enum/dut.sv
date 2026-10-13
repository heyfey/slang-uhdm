// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
typedef enum int { ZERO, ONE } e_e;
class grid; item iarr[4]; int i; int r; e_e e;
  function void probe(); r = iarr[ONE + i].f; r = iarr[e].f; endfunction
endclass
module top; endmodule
