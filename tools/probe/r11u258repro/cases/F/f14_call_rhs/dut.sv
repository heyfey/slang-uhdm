// § forMultiInitAssign258 (two initializers, a call on the right side)
module m; int i, j; logic [7:0] y;
  function automatic int g(int a); return a + 1; endfunction
  always_comb begin
    for (i = g(0), j = 0; i < 4; i++) y = j;
  end
endmodule
module top; m u(); endmodule
