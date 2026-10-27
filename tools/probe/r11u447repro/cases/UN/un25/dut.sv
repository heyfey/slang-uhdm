// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  for (genvar i = 0; i < 2; i++) begin : g
    always @(negedge clk) $display("%b", undecl_x);
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
