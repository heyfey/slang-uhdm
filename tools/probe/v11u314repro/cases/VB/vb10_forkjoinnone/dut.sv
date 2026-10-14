// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
module top; holder h; task t(input int i); fork : f begin int j; j = i; h.idx[j + 1] = 0; end join_none endtask endmodule
