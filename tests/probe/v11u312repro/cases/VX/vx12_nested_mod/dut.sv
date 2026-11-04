// § modTfLvTrailIdxNamesByChain312
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; module inner; holder h; task t(input int i); h.idx[i + 1] = 0; endtask endmodule inner n(); endmodule
