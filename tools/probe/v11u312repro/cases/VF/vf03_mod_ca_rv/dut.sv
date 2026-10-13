// § lateCallIdxNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; wire o; assign o = m[g(1)].b; function automatic int g(int x); return x; endfunction endmodule
