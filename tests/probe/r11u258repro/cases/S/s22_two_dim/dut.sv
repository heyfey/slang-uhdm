// § lvStreamBaseKeepsActual258 (a two-dimensional select as a streaming target)
module m; logic [7:0] mem [4]; logic [3:0] x;
  always_comb {>>{mem[1][3:0]}} = x;
endmodule
module top; m u(); endmodule
