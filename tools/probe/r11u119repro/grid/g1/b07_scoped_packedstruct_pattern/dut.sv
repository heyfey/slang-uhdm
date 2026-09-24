package pkg;
  typedef struct packed { logic [3:0] x; int y; } s_t;
endpackage
module top(output logic [35:0] o);
  pkg::s_t a = '{x: 4'h1, y: 2};
  assign o = a;
endmodule
