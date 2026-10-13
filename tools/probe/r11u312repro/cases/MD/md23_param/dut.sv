// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
module top #(parameter int P = 1); holder h; int i; int r; task t(); h.idx[i + P] = r; endtask initial t(); endmodule
