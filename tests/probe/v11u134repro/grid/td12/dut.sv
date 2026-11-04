// § defNetTypedefEndWrite134
module top(input logic c, output logic o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  localparam int N = 3;
  s_t a [N];
  s_t b [N-1:0];
  assign a[0] = {c, c, c};
  assign b[1] = a[0];
  assign o = b[1].b;
endmodule
