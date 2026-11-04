// § modTfLvTrailIdxNamesByChain312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; task t(input int i); ps.idx[i + 1] = 0; endtask endmodule
