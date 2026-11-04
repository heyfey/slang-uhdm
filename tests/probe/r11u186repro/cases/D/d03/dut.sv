// § synLitUnderscoreDropped186 (a generate loop condition)
module top(output logic [15:0] o);
  for (genvar g = 0; g < 1_6; g++) begin : gl
    assign o[g] = 1'b1;
  end
endmodule
