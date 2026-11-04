// § lvStreamBaseKeepsActual258 (a bit-select streaming target through a struct variable)
module m; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  s_t s; logic x;
  always_comb {>>{s.f[3]}} = x;
endmodule
module top; m u(); endmodule
