// § pkgTfLvTrailIdxNamesByChain312
package p; class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
 holder g; function automatic void f(int i); int k; k = i; g.idx[k + 1] = 0; endfunction endpackage
module top; endmodule
