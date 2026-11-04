// § tagPatParenSpan195 — grid T/t03 (r11u195)
module top (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t s;
  always_comb s = '{a: (4'd1), b: (4'd2 + 4'd1)};
  assign o = s;
endmodule
