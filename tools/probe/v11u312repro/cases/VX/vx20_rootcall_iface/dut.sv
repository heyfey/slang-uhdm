// § lvRootSelCallNameSpan312
typedef struct packed { logic b; logic c; } m_t;
interface ifc2; m_t m[4]; int k; function automatic int g(int x); return x; endfunction always_comb m[g(k)].b = 0; endinterface
module top; ifc2 u(); endmodule
