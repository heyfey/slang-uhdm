// § escIdPpColumnShift146
module top(input logic i, output logic o);
  typedef struct packed { logic \m$ ; logic n; } s_t;
  s_t s;
  assign s.\m$ = i; assign s.n = i;
  assign o = s.\m$ & s.n;
endmodule
