// § hierSelParenBoundPretty417
module top (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } in_t;
  typedef struct packed { in_t a; } s_t;
  s_t s;
  assign o = s.a.d[(i*4)+:4];
endmodule
