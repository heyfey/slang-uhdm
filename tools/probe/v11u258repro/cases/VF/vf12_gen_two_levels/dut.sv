// § forMultiInitAssign258 (two initializers in a process two generate levels down, instance depth 2)
module m; int i, j; logic [7:0] y;
  for (genvar g = 0; g < 2; g++) begin : ga
    if (g == 1) begin : gi
      always_comb begin for (i = 0, j = 1; i < 4; i++) y = j; end
    end
  end
endmodule
module mid; m u(); endmodule
module top; mid w(); endmodule
