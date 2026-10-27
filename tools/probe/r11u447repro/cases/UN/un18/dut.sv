// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  logic [7:0] x;
  always @(posedge clk) x <= {undecl_a, undecl_b};
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
