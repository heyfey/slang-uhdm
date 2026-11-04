// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; task t(); for (int k = 0; k < 2; k++) begin : lb int j; j = k; h.idx[j + 1] = 0; end endtask endmodule
