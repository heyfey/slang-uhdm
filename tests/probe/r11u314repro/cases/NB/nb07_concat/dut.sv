// § tfLvTrailIdxNamedBlkScope314
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; holder h; int r; task t(input int i); begin : b int j; {h.idx[j + 1], r} = 2; end endtask endmodule
