// § forMultiInitAssign258 (two initializers, the first an element select)
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  s_t s; int i, j; logic [7:0] y; logic [7:0] arr [4];
  always_comb begin
    for (arr[1] = 0, i = 0; i < 4; i++) y = arr[1];
  end
endmodule
module top; m u(); endmodule
