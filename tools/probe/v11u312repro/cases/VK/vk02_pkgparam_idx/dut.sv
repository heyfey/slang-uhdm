// § pkgTfLvTrailIdxNamesByChain312
package p; class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
 localparam int N = 1; function automatic void f(holder h, int i); h.idx[N + i] = 0; endfunction endpackage
module top; endmodule
