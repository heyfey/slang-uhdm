// § lvStreamBaseKeepsActual258 (a struct-array element member streaming target)
module m; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  s_t sa [2]; logic [3:0] x;
  always_comb {>>{sa[1].f[3:0]}} = x;
endmodule
module top; m u(); endmodule
