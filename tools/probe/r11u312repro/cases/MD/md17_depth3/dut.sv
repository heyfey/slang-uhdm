// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
module leaf; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask endmodule
module mid; leaf l(); endmodule
module top; mid m(); endmodule
