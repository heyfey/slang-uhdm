module top (input logic [11:0] i, output logic [11:0] o);
  typedef struct packed { logic [11:00] a; } s_t;
  s_t t;
  assign t.a = i;
  assign o = t.a;
endmodule
