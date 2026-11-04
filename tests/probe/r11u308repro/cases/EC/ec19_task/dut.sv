// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; item iarr[4]; int i; int r;
  task probe(); r = iarr[i+1].f; endtask
endclass
module top; endmodule
