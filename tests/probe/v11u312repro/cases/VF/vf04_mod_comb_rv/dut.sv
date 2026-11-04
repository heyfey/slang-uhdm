// § lateCallIdxNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; int k; logic o; always_comb o = m[g(k)].b; function automatic int g(int x); return x; endfunction endmodule
