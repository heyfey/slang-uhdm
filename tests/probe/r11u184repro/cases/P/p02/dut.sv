// § memberSelParenIdxSpan184: continuous-assignment rvalues, a macro-born parenthesized index and an included macro
`include "idx.svh"
typedef struct packed { logic [7:0] f; logic [3:0][1:0] g; } s_t;
module top(input s_t s, input logic [2:0] i, output logic y, output logic z, output logic [1:0] v);
  `define IDX (i+1)
  assign y = s.f[(i)];
  assign z = s.f[`IDX];
  assign v = s.g[`IDX2];
endmodule
