// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; int r; task t(input int i); begin : b int j; j = i; r = h.idx[j + 1]; end endtask endmodule
