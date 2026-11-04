// § forMultiInitAssign258 (two initializers, the second through a member)
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  s_t s; int i, j; logic [7:0] y; logic [7:0] arr [4];
  always_comb begin
    for (i = 0, s.a = 0; i < 4; i++) y = s.a;
  end
endmodule
module top; m u(); endmodule
