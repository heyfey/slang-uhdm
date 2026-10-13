// § pkgTfLvTrailIdxNamesByChain312
package p; class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass function automatic void f(holder h, int i); h.idx[i + 1] += 1; endfunction endpackage
module top; import p::*; holder hh; initial f(hh, 1); endmodule
