// § defNetTypedefEndWrite134
module top(input logic c, output logic o);
  typedef union packed { logic [2:0] w; struct packed { logic [1:0] a; logic b; } s; } u_t;
  u_t a [2];
  assign a[0] = {c, c, c};
  assign o = a[0].s.b;
endmodule
