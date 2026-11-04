// § tfLvTrailIdxNamedBlkScope314
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
class grid; holder h; function void probe(int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endfunction endclass
module top; endmodule
