// § forMultiInitAssign258 (one initializer through a member (forInitSelectLhsBase254's neighbour, a control))
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  s_t s; int i, j; logic [7:0] y; logic [7:0] arr [4];
  always_comb begin
    for (s.a = 0; s.a < 4; s.a++) y = s.a;
  end
endmodule
module top; m u(); endmodule
