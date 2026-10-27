// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  for (genvar g = 0; g < 2; g++) begin : gb end
  initial $display("%b", gb);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
