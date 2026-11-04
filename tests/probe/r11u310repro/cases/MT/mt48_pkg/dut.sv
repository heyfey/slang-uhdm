// § methRecvElemCumName310
package p;
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  function void probe();
    r = iarr[h.k].get();
    r = h.arr[h.idx[r]].get();
  endfunction
endclass
endpackage
module top; endmodule
