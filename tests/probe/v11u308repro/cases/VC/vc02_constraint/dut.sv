// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid;
  rand item iarr[4]; rand int i; int r;
  constraint cc { i < 4; iarr[i].f == 1; }
endclass
module top; endmodule
