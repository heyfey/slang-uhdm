// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
module top(input logic clk); s_t s [2]; always @(posedge clk) s[1].a++; endmodule
