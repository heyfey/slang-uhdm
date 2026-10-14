// § tfLvTrailIdxNamedBlkScope314
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; holder h; if (1) begin : g if (1) begin : g2 task t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask end end endmodule
