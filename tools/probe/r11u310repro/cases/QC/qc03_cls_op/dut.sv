// § idxQualCallNameSpan310
package p; function automatic int f(int x); return x; endfunction endpackage
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; int k; endclass
class grid;
  item iarr[4]; holder h; int r; int i; bit c;
  function void probe();
    r = iarr[p::f(i) + 1].f;
  endfunction
endclass
module top; endmodule
