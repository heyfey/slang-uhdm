// § lvStreamBaseKeepsActual258 (a streaming target whose select index is a call)
module m; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  function automatic int g1(int a); return a + 1; endfunction
  s_t s; logic x;
  always_comb {>>{s.f[g1(1)]}} = x;
endmodule
module top; m u(); endmodule
