// § modTfLvTrailIdxNamesByChain312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
typedef enum { EA, EB } e_t;
module top;
  holder h; int r; int k; int ia[4]; localparam int P = 1; wire [1:0] w;
  task t(input int i); h.idx[i + 1]++; endtask
endmodule
