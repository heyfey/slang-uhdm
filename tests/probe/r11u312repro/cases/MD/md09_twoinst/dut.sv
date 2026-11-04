// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
module child; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask endmodule
module top; child c1(); child c2(); endmodule
