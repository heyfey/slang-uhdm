// § tagPatParenSpan195 — v11u195 fresh: a parenthesized ternary and a parenthesized concatenation in always_comb, a macro-born parenthesis
`define P(x) (x)
module top (input logic [3:0] x, input logic c, output logic [11:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; logic [3:0] d; } s_t;
  s_t s;
  always_comb s = '{a: (c ? x : 4'd0), b: ({2'b0, x[1:0]}), d: `P(x)};
  assign o = s;
endmodule
