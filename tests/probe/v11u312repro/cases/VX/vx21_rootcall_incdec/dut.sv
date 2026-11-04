// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; logic c; } m_t;
module top; m_t m[4]; int k; function automatic int g(int x); return x; endfunction initial m[g(k)].b++; endmodule
