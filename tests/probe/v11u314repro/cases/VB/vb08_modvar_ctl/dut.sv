// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; int m; task t(); begin : b h.idx[m + 1] = 0; end endtask endmodule
