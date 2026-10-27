// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  logic x;
  always @(posedge clk) if (undecl_x) x <= 1'b1;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
