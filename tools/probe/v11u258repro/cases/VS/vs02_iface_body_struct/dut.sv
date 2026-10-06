// § lvStreamBaseKeepsActual258 (a struct member range select as a streaming target inside an interface body)
interface bif; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t; s_t s; logic [3:0] x;
  always_comb {>>{s.f[3:0]}} = x;
endinterface
module top; bif b(); endmodule
