// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; int i; logic clk; function automatic int fn(int x); return x; endfunction always_ff @(posedge clk) m[fn(i)].b <= 0; endmodule
