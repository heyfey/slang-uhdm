// § modTfLvTrailIdxNamesByChain312
typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; int k; always_comb ps.idx[k + 1] = 0; endmodule
