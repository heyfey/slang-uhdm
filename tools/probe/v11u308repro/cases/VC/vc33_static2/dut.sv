// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
class grid; item iarr[4]; int i; static int r;
  static function void probe(item a[4]); r = a[i + 1].f; endfunction
endclass
module top; endmodule
