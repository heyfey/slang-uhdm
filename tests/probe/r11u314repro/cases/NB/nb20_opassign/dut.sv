// § tfLvTrailIdxNamedBlkScope314
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; holder h; task t(input int i); begin : b int j; j = i; h.idx[j + 1] += 1; end endtask endmodule
