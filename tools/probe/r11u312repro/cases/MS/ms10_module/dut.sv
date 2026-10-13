// § memberSelCallIdxParenSpan312
typedef struct packed { logic [3:0][7:0] f; } s_t;
module top; s_t s; logic [7:0] o; function automatic int fn(); return 1; endfunction always_comb o = s.f[fn()]; endmodule
