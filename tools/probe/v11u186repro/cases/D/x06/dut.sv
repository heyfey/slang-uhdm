// § synLitUnderscoreDropped186 (nested generate loops, separators in the step and the inner bound)
module top(output logic [7:0] o);
  for (genvar i = 0; i < 2; i = i + 1_0) begin : a
    for (genvar j = 0; j < 0_4; j++) begin : b
      assign o[i*4+j] = 1'b1;
    end
  end
endmodule
