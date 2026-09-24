// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t; typedef struct { s_t in; int c; } o_t;
module top(input logic clk); s_t s; always @(posedge clk) s.a++; endmodule
