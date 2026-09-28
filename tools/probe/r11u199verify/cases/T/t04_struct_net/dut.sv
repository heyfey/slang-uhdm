// § caTernFillArmKept193
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter bit P = 1) (input s_t x, output s_t y [2]);
  assign y[0] = (P) ? '1 : x;
  assign y[1].a = (P) ? '0 : x.a ^ 4'h1;
  assign y[1].b = x.b;
endmodule
module top (input s_t x, output s_t a [2], output s_t b [2]);
  m #(.P(0)) u_a (.x(x), .y(a));
  m #(.P(1)) u_b (.x(x), .y(b));
endmodule
