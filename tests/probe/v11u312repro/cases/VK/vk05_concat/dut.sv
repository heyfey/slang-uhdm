// § pkgTfLvTrailIdxNamesByChain312
package p; class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
 function automatic void f(holder h, int i); int r; {h.idx[i + 1], r} = 2; endfunction endpackage
module top; endmodule
