// § lvStreamBaseKeepsActual258 (a streaming target that is a struct member without a select)
module m; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  s_t s; logic [7:0] x;
  always_comb {>>{s.f}} = x;
endmodule
module top; m u(); endmodule
