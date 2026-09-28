// § tagPatParenSpan195 — v11u195 fresh: a macro-born parenthesized member value from an included header in another root file, and one in the reading module
module top(input logic [3:0] x, output logic [7:0] o, output logic [7:0] k);
  q::s_t s;
  always_comb s = '{a: `P(x), b: (x)};
  assign o = s;
  assign k = q::K;
endmodule
