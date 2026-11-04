// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
typedef struct packed { s_t [3:0] a; } t_t;
module top; t_t m; int i; function automatic int fn(int x); return x; endfunction always_comb m.a[fn(i)].b = 0; endmodule
