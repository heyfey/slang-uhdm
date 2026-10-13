// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; function automatic int fn(int x); return x; endfunction assign m[fn(1)].b = 0; endmodule
