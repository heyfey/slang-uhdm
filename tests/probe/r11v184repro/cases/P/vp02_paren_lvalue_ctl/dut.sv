// § memberSelParenIdxSpan184 (control): parenthesized member-select indices as assignment targets and inc/dec operands
typedef struct packed { logic [7:0] f; } s_t;
module top (input int i);
  s_t s, t;
  always_comb begin
    s.f[(i)] = 1'b1;
    s.f[((i + 1))] = 1'b0;
  end
  initial t.f[(i)]++;
endmodule
