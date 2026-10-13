// § memberSelCallIdxParenSpan312
typedef struct packed { logic [3:0][7:0] f; } s_t;
module top; s_t s; logic [7:0] o; function automatic int fn(int x); return x; endfunction always_comb o = s.f[fn(1)]; endmodule
