// § forMultiInitAssign258 (a generate-block variable written through a select, v11u254 vf04's shape with two initializers)
module top(output int o);
  for (genvar g = 0; g < 1; g++) begin : gb
    int y [2]; int i;
    initial begin o = 0; for (y[g] = 0, i = 0; y[g] < 2; y[g]++) o++; end
  end
endmodule
