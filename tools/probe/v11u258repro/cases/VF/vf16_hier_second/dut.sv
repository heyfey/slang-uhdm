// § forMultiInitAssign258 (a hierarchical reference into a child instance as the second initializer)
module sub; int x; endmodule
module top(output int o); sub u(); int i;
  initial begin o = 0; for (i = 0, u.x = 0; i < 2; i++) o++; end
endmodule
