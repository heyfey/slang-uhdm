// § defNetTypedefEndWrite134
module top(input logic c, output logic o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  s_t a [2];
  s_t b [5];
  s_t d;
  assign a[0] = {c, c, c};
  assign b[3] = {c, c, c};
  assign d = a[0];
  assign o = b[3].b ^ d.b;
endmodule
