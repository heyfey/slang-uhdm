// § lvStreamBaseKeepsActual258 (plain array element selects as streaming targets (no path))
module m; logic [3:0] arr [2]; logic [7:0] x;
  always_comb {>>{arr[1], arr[0]}} = x;
endmodule
module top; m u(); endmodule
