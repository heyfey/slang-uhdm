// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; task automatic t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask endmodule
