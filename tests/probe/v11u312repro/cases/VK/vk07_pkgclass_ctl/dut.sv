// § pkgTfLvTrailIdxNamesByChain312
package p; class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
 class c; holder h; function void f(int i); h.idx[i + 1] = 0; endfunction endclass endpackage
module top; endmodule
