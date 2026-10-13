// § modTfLvTrailIdxNamesByChain312
typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; function automatic ps_t f(input int i); ps_t q; q = 0; q.idx[i + 1] = 8'h1; return q; endfunction endmodule
