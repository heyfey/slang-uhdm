// § defNetTypedefEndWrite134
typedef struct packed { logic [1:0] a; logic b; } s_t;
module m1(input logic c, output logic o);
  s_t x [3];
  assign x[0] = {c, c, c};
  assign o = x[0].b;
endmodule
module top(input logic c, output logic o1, o2);
  s_t y [0:1];
  assign y[1] = {c, c, c};
  assign o2 = y[1].a[0];
  m1 u(.c(c), .o(o1));
endmodule
