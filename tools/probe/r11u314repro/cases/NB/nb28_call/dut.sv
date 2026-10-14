// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; endclass
module top; holder h; function int f(int x); return x; endfunction task t(input int i); begin : b int j; j = i; h.idx[f(j)] = 0; end endtask endmodule
