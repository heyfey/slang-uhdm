// § pkgTfLvTrailIdxNamesByChain312
package p; class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass function automatic void f(holder h, int i, int j, bit c); h.idx[c ? i : j] = 0; endfunction endpackage
module top; endmodule
