// § lvRootSelCallNameSpan312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; int k; always_comb m[p::f(k)].b = 0; endmodule
