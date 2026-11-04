// § lvStreamBaseKeepsActual258 (a streaming target whose select index is itself a member path)
module m; typedef struct packed { logic [7:0] f; logic [2:0] k; } s_t;
  s_t s, t; logic x;
  always_comb {>>{s.f[t.k]}} = x;
endmodule
module top; m u(); endmodule
