// § methTailIdxNestShape310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; int idx[4]; endclass
module top; item iarr[4]; holder h; int r; int i;
  initial r = iarr[h.k].get();
  always @(i) r = iarr[h.idx[i]].get();
endmodule
