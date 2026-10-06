// § forInitSelectLhsBase254 (a hierarchical base into a child instance, and a variable of the enclosing generate block)
module sub; int x [2]; endmodule
module top(output int o);
  sub u();
  for (genvar g = 0; g < 1; g++) begin : gb
    int y [2];
    initial begin o = 0; for (y[g] = 0; y[g] < 2; y[g]++) o++; end
  end
  initial begin for (u.x[0] = 0; u.x[0] < 2; u.x[0]++) o++; end
endmodule
