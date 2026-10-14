// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
interface ifc; holder h; endinterface
module top; ifc u(); task t(input int i); begin : b int j; j = i; u.h.idx[j + 1] = 0; end endtask endmodule
