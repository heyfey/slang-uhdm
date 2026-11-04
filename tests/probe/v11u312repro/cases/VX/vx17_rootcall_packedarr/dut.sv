// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t pa[4]; int k; function automatic int g(int x); return x; endfunction always_comb pa[g(k)].idx[0] = 0; endmodule
