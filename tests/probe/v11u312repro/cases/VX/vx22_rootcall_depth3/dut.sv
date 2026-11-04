// § lvRootSelCallNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module c3; m_t m[4]; int k; function automatic int g(int x); return x; endfunction always_comb m[g(k)].b = 0; endmodule
module c2; c3 u(); endmodule
module top; c2 u(); endmodule
