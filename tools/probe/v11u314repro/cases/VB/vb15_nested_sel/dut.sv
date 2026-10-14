// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; int m[4]; task t(input int i); begin : b int j; j = i; h.idx[m[j] + j] = 0; end endtask endmodule
