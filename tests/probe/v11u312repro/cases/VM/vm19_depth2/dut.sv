// § modTfLvTrailIdxNamesByChain312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module sub; holder h; int r; task t(input int i); h.idx[i + 1] = r; endtask endmodule
module mid; sub u(); endmodule
module top; mid m(); endmodule
