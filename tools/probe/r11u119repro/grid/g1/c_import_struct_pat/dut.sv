package pkg;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
endpackage
module top import pkg::*; (output logic [7:0] o);
  s_t a = '{x: 4'h1, y: 4'h2};
  assign o = a;
endmodule
