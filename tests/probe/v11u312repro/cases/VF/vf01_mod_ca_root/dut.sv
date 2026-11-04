// § lateCallIdxNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; assign m[g(1)].b = 1'b0; function automatic int g(int x); return x; endfunction endmodule
