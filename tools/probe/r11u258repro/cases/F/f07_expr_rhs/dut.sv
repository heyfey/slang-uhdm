// § forMultiInitAssign258 (two initializers, the second's right side an expression)
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  s_t s; int i, j; logic [7:0] y; logic [7:0] arr [4];
  always_comb begin
    for (i = 0, j = i + 1; i < 4; i++) y = j;
  end
endmodule
module top; m u(); endmodule
