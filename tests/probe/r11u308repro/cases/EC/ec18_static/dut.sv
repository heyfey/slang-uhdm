// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; static item iarr[4]; static int r;
  static function void probe(int i); r = iarr[i+1].f; endfunction
endclass
module top; endmodule
