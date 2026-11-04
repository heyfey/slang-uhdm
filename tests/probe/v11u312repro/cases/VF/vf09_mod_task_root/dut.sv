// § lateCallIdxNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; task t(input int i); m[g(i)].b = 1; endtask function automatic int g(int x); return x; endfunction endmodule
