// § forMultiInitAssign258 (a multi-initializer loop born in a macro body)
`define LOOP(A, B) for (A = 0, B = 0; A < 4; A++) y = B;
module m; int i, j; logic [7:0] y;
  always_comb begin `LOOP(i, j) end
endmodule
module top; m u(); endmodule
