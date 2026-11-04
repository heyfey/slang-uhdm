// § tagPatParenSpan195 — v11u195 fresh: parenthesized non-constant member values in a continuous assignment, a ternary value, nested parentheses around a binary
module top (input logic [3:0] x, input logic [3:0] y, input logic c, output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t s;
  assign s = '{a: (x), b: (c ? y : x)};
  assign o = s;
  s_t s2;
  always_comb s2 = '{a: ((x) + (y)), b: ((y))};
endmodule
