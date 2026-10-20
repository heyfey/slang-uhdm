// § hierSelParenBoundPretty417
module sub #(parameter int N = 4) (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  s_t s;
  assign o = s.d[(N*i)+:4];
endmodule
module top (input logic [3:0] i, output logic [3:0] o1, output logic [3:0] o2);
  sub #(.N(2)) u1 (.i(i), .o(o1));
  sub #(.N(4)) u2 (.i(i), .o(o2));
endmodule
