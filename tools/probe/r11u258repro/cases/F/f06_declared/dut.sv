// § forMultiInitAssign258 (two declared initializers)
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  s_t s; int i, j; logic [7:0] y; logic [7:0] arr [4];
  always_comb begin
    for (int k = 0, l = 0; k < 4; k++) y = l;
  end
endmodule
module top; m u(); endmodule
