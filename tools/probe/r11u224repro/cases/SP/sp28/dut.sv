// § strLitPpEscIdShift224
module top(output string o[2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign o[g] = "a\nb` c";
  end
endmodule
