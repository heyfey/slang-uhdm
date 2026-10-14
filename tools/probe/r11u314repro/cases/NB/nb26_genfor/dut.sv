// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; endclass
module top; holder h; for (genvar g = 0; g < 2; g++) begin : gf task t(input int i); begin : b int j; j = i + g; h.idx[j + 1] = 0; end endtask end endmodule
