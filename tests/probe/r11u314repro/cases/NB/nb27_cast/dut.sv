// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; endclass
module top; holder h; task t(input int i); begin : b int j; j = i; h.idx[int'(j)] = 0; end endtask endmodule
