// § contAssignLhsTsUnparented134
module top(input logic c, output logic [1:0] o);
  typedef struct packed { logic [1:0] a; logic b; } in_t;
  typedef struct packed { in_t inner; logic [3:0] d; } s_t;
  s_t s;
  assign s.inner = '{a: 2'b10, b: c};
  assign s.d = 4'h0;
  assign o = s.inner.a;
endmodule
