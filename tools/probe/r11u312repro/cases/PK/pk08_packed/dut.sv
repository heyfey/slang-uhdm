// § pkgTfLvTrailIdxNamesByChain312
package p; typedef struct packed { logic [3:0][7:0] idx; } h_t; h_t s; int k; function automatic void f(); s.idx[k + 1] = 0; endfunction endpackage
module top; endmodule
