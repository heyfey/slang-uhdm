// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; task t(input int j); begin : b int j; j = 1; h.idx[j + 1] = 0; end endtask endmodule
