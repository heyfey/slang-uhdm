// § lvRootSelCallNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; function automatic int g(int x); return x; endfunction assign w = 1'b0; always_comb m[g(w)].b = 0; endmodule
