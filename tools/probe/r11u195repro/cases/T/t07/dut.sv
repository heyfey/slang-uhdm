// § tagPatParenSpan195 — grid T/t07 (r11u195)
module top (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t s;
  assign s = '{a: (4'd1), b: 4'd2};
  assign o = s;
endmodule
