// § pkgTfLvTrailIdxNamesByChain312
package p; class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
 int ga[4]; function automatic void f(holder h, int i); h.idx[ga[i] + 1] = 0; endfunction endpackage
module top; endmodule
