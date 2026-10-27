// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk, input a);
  logic x;
  always_ff @(posedge clk) x <= a & undecl_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
