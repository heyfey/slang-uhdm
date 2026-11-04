// § idxQualCallNameSpan310
package p; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  function void probe();
    r = iarr[p::f(h.k)].get();
    r = iarr[p::f(1) + h.k].get();
  endfunction
endclass
module top; endmodule
