// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
module top; holder h; int i; int j; int r; task t(); h.idx2[i + 1][j] = r; endtask initial t(); endmodule
