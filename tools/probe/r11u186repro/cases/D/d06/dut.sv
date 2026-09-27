// § synLitUnderscoreDropped186 (a step with a separator: golden's elaborated loop reads it as 1, report only)
module top(output logic [15:0] o);
  for (genvar g = 1_0; g >= 0; g = g - 1_0) begin : gl
    assign o[g] = 1'b0;
  end
endmodule
