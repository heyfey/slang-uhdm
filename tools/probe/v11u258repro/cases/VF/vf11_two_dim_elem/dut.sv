// § forMultiInitAssign258 (a two-dimensional unpacked element and a packed part select as initializers)
module m; int a [2][2]; logic [7:0] b; logic [7:0] y;
  always_comb begin for (a[1][0] = 0, b[3:0] = 4'd1; a[1][0] < 4; a[1][0]++) y = b; end
endmodule
module top; m u(); endmodule
