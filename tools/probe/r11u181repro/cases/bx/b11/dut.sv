// § bitSelParenIdxSpan181 — parenthesized indices in struct member paths (trailing and middle selects) (control: no r11u181 law fires)
module top(input int k, output logic y, output logic [7:0] z);
  typedef struct packed { logic [3:0][7:0] w; } s_t;
  s_t m;
  assign y = m.w[(k+1)][0];
  assign z = m.w[(k)];
endmodule
