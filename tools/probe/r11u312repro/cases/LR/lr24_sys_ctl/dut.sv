// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; int i; always_comb m[$clog2(i)].b = 0; endmodule
