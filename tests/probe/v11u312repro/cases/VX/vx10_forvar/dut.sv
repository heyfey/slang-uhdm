// § modTfLvTrailIdxNamesByChain312
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; holder h; function void f(); for (int j = 0; j < 2; j++) h.idx[j + 1] = 0; endfunction endmodule
