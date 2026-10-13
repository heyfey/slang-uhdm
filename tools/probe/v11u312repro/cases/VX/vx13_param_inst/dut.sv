// § modTfLvTrailIdxNamesByChain312
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module sub #(int W = 1); holder h; task t(input int i); h.idx[i + W] = 0; endtask endmodule
module top; sub #(2) a(); sub #(3) b(); endmodule
