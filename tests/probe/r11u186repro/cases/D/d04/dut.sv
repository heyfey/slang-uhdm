// § synLitUnderscoreDropped186 (an initial value and an if-generate condition)
module top #(parameter int N = 1_2) (output logic [15:0] o);
  for (genvar g = 1_0; g >= 0; g--) begin : gl
    assign o[g] = 1'b0;
  end
  if (N > 1_0) begin : gi
    assign o[15] = 1'b1;
  end
endmodule
