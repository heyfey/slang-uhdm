// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; task t(input int i); begin : b int j; fork : f h.idx[j + 1] = 0; join end endtask endmodule
