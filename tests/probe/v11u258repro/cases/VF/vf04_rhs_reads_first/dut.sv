// § forMultiInitAssign258 (the second initializer reads the first)
module m; int i, j; logic [7:0] y;
  always_comb begin for (i = 0, j = i + 1; i < 4; i++) y = j; end
endmodule
module top; m u(); endmodule
