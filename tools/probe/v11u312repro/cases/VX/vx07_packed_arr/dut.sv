// § modTfLvTrailIdxNamesByChain312
typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t pa[2]; task t(input int i); pa[1].idx[i + 1] = 0; endtask endmodule
