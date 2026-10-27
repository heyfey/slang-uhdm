// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  for (genvar gi = 0; gi < 2; gi++) begin : g end
  assign w = gi;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
