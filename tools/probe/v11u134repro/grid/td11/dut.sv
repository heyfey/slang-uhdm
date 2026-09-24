// § defNetTypedefEndWrite134
module top(input logic c, output logic o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  s_t a [2][3];
  assign a[1][2] = {c, c, c};
  assign o = a[1][2].b;
endmodule
