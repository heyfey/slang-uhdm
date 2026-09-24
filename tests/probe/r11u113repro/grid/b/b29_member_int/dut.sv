package pk; parameter int P = 5; parameter int Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  typedef struct packed { logic [P:0] a; logic b; } s_t;
  s_t x;
  assign x = i[6:0];
  assign o = x.a;
endmodule
