// § elabClsNonTrailIdxUnstored308
class item; int f; int g[4]; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; endclass
interface class ic; pure virtual function int g(); endclass
class grid implements ic; item iarr[4]; int i;
  virtual function int g(); return iarr[i + 1].f; endfunction
endclass
module top; endmodule
