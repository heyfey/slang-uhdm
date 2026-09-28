// § tagPatParenSpan195 — grid T/t10 (r11u195)
module top (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef struct packed { s_t x; } w_t;
  w_t w;
  always_comb w = '{x: ('{a: 4'd1, b: 4'd2})};
  assign o = w;
endmodule
