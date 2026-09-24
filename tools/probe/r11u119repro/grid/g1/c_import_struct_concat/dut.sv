package pkg;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
endpackage
module top import pkg::*; (input logic [3:0] i, output logic [7:0] o);
  s_t a = {i, i};
  assign o = a;
endmodule
