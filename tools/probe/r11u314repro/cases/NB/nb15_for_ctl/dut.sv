// § tfLvTrailIdxNamedBlkScope314
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; holder h; task t(); for (int k = 0; k < 2; k++) h.idx[k + 1] = 0; endtask endmodule
