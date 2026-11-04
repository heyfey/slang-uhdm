// § tfLvTrailIdxNamedBlkScope314
package pk; class holder; int idx[4]; endclass function automatic void f(holder h, int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endfunction endpackage
module top; endmodule
