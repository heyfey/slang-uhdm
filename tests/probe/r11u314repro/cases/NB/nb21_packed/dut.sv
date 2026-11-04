// § tfLvTrailIdxNamedBlkScope314
typedef struct packed { logic [3:0] [7:0] idx; } ps_t;
module top; ps_t h; task t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask endmodule
