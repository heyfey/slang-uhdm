// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
module top; for (genvar g = 0; g < 1; g++) begin : gb holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask end endmodule
