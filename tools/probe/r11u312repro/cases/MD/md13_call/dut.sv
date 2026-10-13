// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
module top; holder h; int i; int r; function int f(int x); return x; endfunction task t(); h.idx[f(i)] = r; endtask initial t(); endmodule
