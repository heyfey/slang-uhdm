// § lvStreamBaseKeepsActual258 (a bit-select streaming target through a struct, in a macro body)
`define wr(S) \
  always_comb {>>{S.f[3]}} = x;
module m; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  s_t s; logic x;
  `wr(s)
endmodule
module top; m u(); endmodule
