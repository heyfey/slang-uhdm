// § lateCallIdxNameSpan312
typedef struct packed { logic b; logic c; } m_t;
module top; m_t m[4]; if (1) begin : gb assign m[g(2)].b = 1'b0; end function automatic int g(int x); return x; endfunction endmodule
