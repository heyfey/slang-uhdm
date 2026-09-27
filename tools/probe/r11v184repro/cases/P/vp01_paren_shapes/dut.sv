// § memberSelParenIdxSpan184: double parentheses, a parenthesized operand of an operation index, a nested member, a condition, a continuous assignment and a macro index
typedef struct packed { logic [7:0] f; } in_t;
typedef struct packed { in_t a; logic [7:0] f; } s_t;
`define IDX (i)
module top (input int i, output logic y1, y2, y3, y4, y5, y6);
  s_t s;
  assign y5 = s.f[(i)];
  always_comb begin
    y1 = s.f[((i))];
    y2 = s.f[(i) + 1];
    y3 = s.a.f[(i)];
    if (s.f[(i - 1)]) y4 = 1'b1; else y4 = 1'b0;
    y6 = s.f[`IDX];
  end
endmodule
