// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; task t(); begin : b static int j = 0; h.idx[j + 1] = 0; end endtask endmodule
