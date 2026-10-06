// § forMultiInitAssign258 (two initializers, the first through a struct member)
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  s_t s; int i; logic [7:0] y;
  always_comb begin
    for (s.a = 0, i = 0; i < 4; i++) y = s.a;
  end
endmodule
module top; m u(); endmodule
