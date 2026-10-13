// § ipsBaseSelCallRender312
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; int i; function automatic int f(int x); return x; endfunction always_comb a.v[f(i) +: 2] = 2'b0; endmodule
