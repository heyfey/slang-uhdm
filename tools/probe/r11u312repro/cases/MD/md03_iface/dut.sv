// § modTfLvTrailIdxNamesByChain312
class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass
interface ifc; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask endinterface
module top; ifc u(); endmodule
