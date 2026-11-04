// § lateCallIdxNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; int k; always_comb m[g(k)].b = 0; function automatic int g(int x); return x; endfunction endmodule
