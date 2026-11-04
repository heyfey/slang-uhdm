// § tfLvTrailIdxNamedBlkScope314
class holder; logic [7:0] v; endclass
module top; holder h; task t(input int i); begin : b int j; j = i; h.v[j +: 2] = 0; end endtask endmodule
