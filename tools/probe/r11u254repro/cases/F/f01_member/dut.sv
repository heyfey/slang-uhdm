// § forInitSelectLhsBase254 (an outside for-loop variable written through a struct member: the r11v124 hx/x02 crash shape)
typedef struct { int a; int b; } s_t;
module top(output int o); s_t s; initial begin o = 0; for (s.a = 0; s.a < 4; s.a++) o = o + 1; end endmodule
