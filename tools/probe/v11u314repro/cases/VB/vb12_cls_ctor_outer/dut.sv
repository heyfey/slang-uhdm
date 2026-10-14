// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; int idx2[4][4]; endclass
class grid; holder h; int i; task probe(); begin : b int j; begin : c h.idx[j + i] = 0; end end endtask endclass
module top; endmodule
