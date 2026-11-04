// § forMultiInitAssign258 (two initializers in a for-generate block process)
module m; int i [2], j [2]; logic [7:0] y [2];
  for (genvar g = 0; g < 2; g++) begin : gb
    always_comb begin
      for (i[g] = 0, j[g] = 1; i[g] < 4; i[g]++) y[g] = j[g];
    end
  end
endmodule
module top; m u(); endmodule
