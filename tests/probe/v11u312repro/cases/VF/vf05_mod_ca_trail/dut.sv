// § lateCallIdxNameSpan312
typedef struct packed { logic [3:0] v; } t_t;
module top; t_t s; wire o; assign o = s.v[g(1)]; function automatic int g(int x); return x; endfunction endmodule
