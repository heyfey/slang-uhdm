// § modTfLvTrailIdxNamesByChain312
typedef struct packed { logic [3:0][7:0] idx; } h_t;
module top; h_t h; int i; logic [7:0] r; task t(); h.idx[i + 1] = r; endtask initial t(); endmodule
