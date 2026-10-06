// § lvStreamBaseKeepsActual258 (a hierarchical reference into a child instance as a streaming target)
module sub; logic [7:0] r; endmodule
module top; sub u(); logic [3:0] x;
  always_comb {>>{u.r[3:0]}} = x;
endmodule
