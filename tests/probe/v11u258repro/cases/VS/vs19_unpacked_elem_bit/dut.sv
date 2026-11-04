// § lvStreamBaseKeepsActual258 (a bit select of an unpacked array element and of a two-level struct member as streaming targets)
module m; typedef struct packed { logic [3:0] a; } in_t; typedef struct packed { in_t i; logic [3:0] b; } s_t;
  logic [7:0] arr [2]; s_t s; logic [1:0] x;
  always_comb {>>{arr[1][3], s.i.a[2]}} = x;
endmodule
module top; m u(); endmodule
