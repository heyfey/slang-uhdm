// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; function automatic int fn(int x); return x; endfunction assign w = 1'b1; always_comb m[fn(w)].b = 0; endmodule
